From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] Two small fixes to IPoIB support for bonding:
Date: Wed, 17 Oct 2007 18:15:34 -0700
Message-ID: <29022.1192670134@death>
References: <1192667871139-git-send-email-fubar@us.ibm.com> <1192667875793-git-send-email-fubar@us.ibm.com> <11926678763205-git-send-email-fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:45861 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761221AbXJRBPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 21:15:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I1FnM7023151
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:49 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I1FmOW046388
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I1FhGr012192
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 21:15:43 -0400
In-reply-to: <11926678763205-git-send-email-fubar@us.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jay Vosburgh <fubar@us.ibm.com> wrote:

>	1- copy header_ops from slave to bonding for IPoIB slaves
>	2- move release and destroy logic to UNREGISTER from GOING_DOWN
>	   notifier to prevent double release
>
>	Set bonding to version 3.2.1.
>---
> drivers/net/bonding/bond_main.c |   11 +++++------
> drivers/net/bonding/bonding.h   |    4 ++--
> 2 files changed, 7 insertions(+), 8 deletions(-)
[...]

	Ignore this patch, it's already in the mainline.  It got
reposted because I'm a bonehead.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
