From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Wed, 25 Oct 2006 14:51:37 +0200
Message-ID: <20061025125137.GC25830@c3po.0xdef.net>
References: <453D61E8.8020400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c3po.0xdef.net ([217.172.181.57]:34825 "EHLO c3po.0xdef.net")
	by vger.kernel.org with ESMTP id S964807AbWJYMvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 08:51:38 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <453D61E8.8020400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ben Greear | 2006-10-23 17:44:24 [-0700]:

>Since IOCTLs are out of favor these days, what would be
>a preferred way to get a block of binary data out of the
>kernel?

I suggest netlink socket for that purpose! Netlink scales also well if the
amount of data "surprisedly" rise.

>Thanks,
>Ben

HGN

