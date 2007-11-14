From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Wed, 14 Nov 2007 23:11:19 +0100
Message-ID: <20071114221119.GA20108@electric-eye.fr.zoreil.com>
References: <20071108143205.GA22490@mpi-sb.mpg.de> <47332F1F.5040401@trash.net> <20071114084420.GA29241@mpi-sb.mpg.de> <473AB82F.8050801@trash.net> <20071114094508.GA6004@mpi-sb.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pcernko@mpi-sws.mpg.de
To: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42709 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752720AbXKNWNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 17:13:50 -0500
Content-Disposition: inline
In-Reply-To: <20071114094508.GA6004@mpi-sb.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Jochem <rainer.jochem@mpi-sb.mpg.de> :
[...]
> --- net/ipv4/ipconfig.c.orig	2007-11-14 09:16:15.800566536 +0100
> +++ net/ipv4/ipconfig.c	2007-11-14 10:34:22.471219274 +0100
> @@ -139,6 +139,8 @@ __be32 ic_servaddr = NONE;	/* Boot serve
>  __be32 root_server_addr = NONE;	/* Address of NFS server */
>  u8 root_server_path[256] = { 0, };	/* Path to mount as root */
>  
> +static char vendor_class_identifier[253]; /* vendor class identifier */
> +

ic_dhcp_init_options is __init. Should it not be __initdata ?

-- 
Ueimor
