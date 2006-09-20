From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 3/4] Make sure ip_vs_ftp ports are valid
Date: Wed, 20 Sep 2006 12:29:45 +0200
Message-ID: <45111819.1030309@trash.net>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org> <20060901101756.637601000@tabatha.lab.ultramonkey.org> <44FB60C7.30300@trash.net> <20060904004401.GD30287@verge.net.au> <20060904020253.GA8761@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:13774 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750895AbWITKdA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 06:33:00 -0400
To: Horms <horms@verge.net.au>
In-Reply-To: <20060904020253.GA8761@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Horms wrote:
> Here is the revised patch.
> 
>
> [IPVS] Make sure ip_vs_ftp ports are valid
>
> I'm not entirely sure what happens in the case of a valid port,
> at best it'll be silently ignored. This patch ensures that
> the port values are unsigned short values, and thus always valid.
>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-Off-By: Simon Horman <horms@verge.net.au>
>
> Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
> ===================================================================
> --- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-04
10:47:09.000000000 +0900
> +++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-04 10:59:30.000000000
+0900
> @@ -44,8 +44,8 @@
>   * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
>   * First port is set to the default port.
>   */
> -static int ports[IP_VS_APP_MAX_PORTS] = {21, 0};
> -module_param_array(ports, int, NULL, 0);
> +static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
> +module_param_array(ports, ushort, NULL, 0);
>  MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
>
>  /*

It looks like the wrong patch went in:

http://marc.theaimsgroup.com/?l=git-commits-head&m=115862407021941&w=2

