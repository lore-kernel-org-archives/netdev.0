From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make pktgen depends on procfs [2.6.0-test3]
Date: Tue, 19 Aug 2003 21:08:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819210819.42196998.davem@redhat.com>
References: <200308182326.10798.bellucda@tiscali.it>
	<16194.11289.761163.104079@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bellucda@tiscali.it, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16194.11289.761163.104079@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 15:54:33 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> diff -urN 1.0/net/Kconfig 1.1/net/Kconfig
> --- 1.0/net/Kconfig	2003-08-18 23:25:02.000000000 +0200
> +++ 1.1/net/Kconfig	2003-08-18 23:25:13.000000000 +0200
> @@ -661,6 +661,7 @@
>  
>  config NET_PKTGEN
>  	tristate "Packet Generator (USE WITH CAUTION)"
> +	depends on PROC_FS

Applied, thanks.
