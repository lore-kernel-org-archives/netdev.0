From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: avoid use of implicit declarations
Date: Tue, 3 Jan 2012 13:57:24 -0800
Message-ID: <20120103135724.0e23e797@nehalam.linuxnetplumber.net>
References: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
	<alpine.LNX.2.01.1112312321370.6978@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50883 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754904Ab2ACV51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 16:57:27 -0500
In-Reply-To: <alpine.LNX.2.01.1112312321370.6978@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Dec 2011 23:22:05 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> From: Jan Engelhardt <jengelh@medozas.de>
> Date: 2011-12-31 23:16:27.428349795 +0100
> 
> gcc -DLIBDIR=\"/usr/lib64\" -D_GNU_SOURCE -fmessage-length=0 -O2 -Wall -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -g -Wstrict-prototypes -fPIC -DXT_LIB_DIR=\"/usr/lib64/xtables\" -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib64\" -fPIC   -c -o ipx_pton.o ipx_pton.c
> In file included from ../include/utils.h:8:0,
>                  from ipx_ntop.c:5:
> ../include/libnetlink.h: In function 'rta_getattr_u64':
> ../include/libnetlink.h:84:2: warning: implicit declaration of function 'memcpy'
> ../include/libnetlink.h:84:2: warning: incompatible implicit declaration of built-in function 'memcpy'
> 
> diff --git a/include/libnetlink.h b/include/libnetlink.h
> index b237579..b0656ce 100644
> --- a/include/libnetlink.h
> +++ b/include/libnetlink.h
> @@ -1,6 +1,7 @@
>  #ifndef __LIBNETLINK_H__
>  #define __LIBNETLINK_H__ 1
>  
> +#include <string.h>
>  #include <asm/types.h>
>  #include <linux/netlink.h>
>  #include <linux/rtnetlink.h>


Applied.
