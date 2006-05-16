From: Christian Borntraeger <borntrae@de.ibm.com>
Subject: Re: [RFC] changing value of NETDEV_ALIGN to cacheline size
Date: Tue, 16 May 2006 17:16:59 +0200
Message-ID: <200605161716.59759.borntrae@de.ibm.com>
References: <20060515080258.bdcfba5f.rdunlap@xenotime.net> <4468F50B.9000102@hp.com> <20060515.154955.114682456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, rdunlap@xenotime.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:23264 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP id S932085AbWEPPRC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 11:17:02 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k4GFH15p094830
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 15:17:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4GFHwBi126490
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 16:17:58 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11/8.13.3) with ESMTP id k4GFH0HQ026435
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 16:17:00 +0100
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060515.154955.114682456.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 May 2006 00:49, David S. Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 15 May 2006 14:39:23 -0700
>
> > How about:
>
> How about, just leave it alone? :-)

Agreed. Currently it only makes a difference with slab debugging, which=
 hurts=20
performance no matter what we do.



--=20
Mit freundlichen Gr=FC=DFen / Best Regards

Christian Borntraeger
Linux Software Engineer zSeries Linux & Virtualization



