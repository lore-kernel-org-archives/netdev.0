From: Daniele Bellucci <bellucda@tiscali.it>
Subject: Re: [PATCH] make pktgen depends on procfs [2.6.0-test3]
Date: Tue, 19 Aug 2003 15:58:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308191558.22513.bellucda@tiscali.it>
References: <200308182326.10798.bellucda@tiscali.it> <16194.11289.761163.104079@robur.slu.se>
Reply-To: bellucda@tiscali.it
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16194.11289.761163.104079@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  Hello!
>  It should be changed to:
>
> diff -urN 1.0/net/Kconfig 1.1/net/Kconfig
> --- 1.0/net/Kconfig	2003-08-18 23:25:02.000000000 +0200
> +++ 1.1/net/Kconfig	2003-08-18 23:25:13.000000000 +0200
> @@ -661,6 +661,7 @@
>
>  config NET_PKTGEN
>  	tristate "Packet Generator (USE WITH CAUTION)"
> +	depends on PROC_FS
>  	---help---
>  	  This module will inject preconfigured packets, at a configurable
>  	  rate, out of a given interface.  It is used for network interface
>
>  > +	depends on CONFIG_PROC_FS
>
> Cheers.
> 						--ro

Argh !%$@#! i've post the wrong version ;(


-- 
Daniele.
