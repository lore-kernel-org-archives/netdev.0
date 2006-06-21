From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/6] ehea: pHYP interface
Date: Wed, 21 Jun 2006 08:36:05 -0700
Message-ID: <ada4pyemsgq.fsf@cisco.com>
References: <44993E48.8060600@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, meder@de.ibm.com,
	raisch@de.ibm.com, schickhj@de.ibm.com, themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:29781 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932193AbWFUPgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 11:36:10 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <44993E48.8060600@de.ibm.com> (Jan-Bernd Themann's message of "Wed, 21 Jun 2006 14:40:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this code needs to be refactored so that it can share with the
ehca InfiniBand driver (which should be merged upstream soon).  For
example, you have ehea_hcall_7arg_7ret() and the ehca driver has an
identical ehca_hcall_7arg_7ret().

Also:

 > +++ kernel/drivers/net/ehea/ehea_hcall.h	2006-06-21 04:44:50.158485520 -0700

 > +/**
 > + * This file contains HCALL defines that are to be included in the appropriate
 > + * kernel files later
 > + */

this stuff should go in <asm-powerpc/hvcall.h> with the other
constants, right?
