From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Mon, 19 Nov 2007 21:56:30 -0800 (PST)
Message-ID: <20071119.215630.106621215.davem@davemloft.net>
References: <473AB82F.8050801@trash.net>
	<20071114094508.GA6004@mpi-sb.mpg.de>
	<20071114221119.GA20108@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rainer.jochem@mpi-sb.mpg.de, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pcernko@mpi-sws.mpg.de
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755899AbXKTF4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:56:31 -0500
In-Reply-To: <20071114221119.GA20108@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 14 Nov 2007 23:11:19 +0100

> Rainer Jochem <rainer.jochem@mpi-sb.mpg.de> :
> [...]
> > --- net/ipv4/ipconfig.c.orig	2007-11-14 09:16:15.800566536 +0100
> > +++ net/ipv4/ipconfig.c	2007-11-14 10:34:22.471219274 +0100
> > @@ -139,6 +139,8 @@ __be32 ic_servaddr = NONE;	/* Boot serve
> >  __be32 root_server_addr = NONE;	/* Address of NFS server */
> >  u8 root_server_path[256] = { 0, };	/* Path to mount as root */
> >  
> > +static char vendor_class_identifier[253]; /* vendor class identifier */
> > +
> 
> ic_dhcp_init_options is __init. Should it not be __initdata ?

I think so and I've made that change in net-2.6.25, thanks.
