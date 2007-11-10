From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 05/05] ipv6: RFC4214 Support (3)
Date: Sat, 10 Nov 2007 10:44:17 +0900 (JST)
Message-ID: <20071110.104417.24374383.yoshfuji@linux-ipv6.org>
References: <473371B3.5030908@yahoo.com>
	<4734FCEF.3080301@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: osprey67@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39790 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369AbXKJBoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 20:44:11 -0500
In-Reply-To: <4734FCEF.3080301@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4734FCEF.3080301@yahoo.com> (at Fri, 09 Nov 2007 16:35:59 -0800), osprey67 <osprey67@yahoo.com> says:

> --- linux-2.6.24-rc2/include/linux/if_tunnel.h.orig	2007-11-09 09:06:16.000000000 -0800
> +++ linux-2.6.24-rc2/include/linux/if_tunnel.h	2007-11-09 15:49:54.000000000 -0800
> @@ -25,6 +25,8 @@ struct ip_tunnel_parm
>  	__be16			o_flags;
>  	__be32			i_key;
>  	__be32			o_key;
> +	__be32			router;
> +	__be32			lifetime;
>  	struct iphdr		iph;
>  };
>  

No, you cannot simply change this.
If you change ioctl structure, you need to change
constants for SIOC{GET,ADD,CHG,DEL}TUNNEL.
Rename ole ones to OSIOxxx and assign new values.

If possible, new iproute2 should work with old kernels, and
old iproute2 should work with new kernels (without new features).

--yoshfuji
