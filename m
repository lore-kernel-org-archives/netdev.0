From: Heiko J Schick <schihei@de.ibm.com>
Subject: Re: [PATCH 2/6] ehea: pHYP interface
Date: Mon, 26 Jun 2006 18:17:08 +0200
Message-ID: <44A00884.2090601@de.ibm.com>
References: <44993E48.8060600@de.ibm.com> <ada4pyemsgq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, meder@de.ibm.com,
	raisch@de.ibm.com, schickhj@de.ibm.com, themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:48317 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750742AbWFZQQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 12:16:46 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5QGGjtx154550
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 16:16:45 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5QGI75I071892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 17:18:07 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5QGGicv005998
	for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 17:16:45 +0100
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <ada4pyemsgq.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> I think this code needs to be refactored so that it can share with the
> ehca InfiniBand driver (which should be merged upstream soon).  For
> example, you have ehea_hcall_7arg_7ret() and the ehca driver has an
> identical ehca_hcall_7arg_7ret().

In genreral this is a good approach, but we think it will be a lengthy
process until the same code base is accepted from both - Network community
(keep it as simple as possible) vs. IB community (support full IB
functionallity). Another thing which makes it quite challenging is that
hypervisor calls have subtle little differences between eHCA and eHEA.

> Also:
> 
>  > +++ kernel/drivers/net/ehea/ehea_hcall.h	2006-06-21 04:44:50.158485520 -0700
> 
>  > +/**
>  > + * This file contains HCALL defines that are to be included in the appropriate
>  > + * kernel files later
>  > + */
> 
> this stuff should go in <asm-powerpc/hvcall.h> with the other
> constants, right?

Yes, that would be the next step.

Regards,
	Heiko

