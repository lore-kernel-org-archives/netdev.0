From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] 2.4 lacks dummy SET_NETDEV_DEV
Date: Tue, 2 Dec 2003 03:28:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202032825.12ded81f.davem@redhat.com>
References: <20031110181917.GA25846@ee.oulu.fi>
	<20031110221430.GA26556@ee.oulu.fi>
	<20031110221429.04732a57.davem@redhat.com>
	<20031202104024.GA9163@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, marcelo.tosatti@cyclades.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031202104024.GA9163@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 12:40:25 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> On Mon, Nov 10, 2003 at 10:14:29PM -0800, David S. Miller wrote:
> > I agree, someone should merge in the dummy SET_NETDEV_DEV once
> > Marcelo starts up 2.4.24-preX
>
> Ping :-)

Yes Marcelo, please apply this.

> --- linux-2.4.22-1.2115.nptl/include/linux/netdevice.h.orig	2003-11-10 20:08:42.922635848 +0200
> +++ linux-2.4.22-1.2115.nptl/include/linux/netdevice.h	2003-11-10 20:09:09.754556776 +0200
> @@ -456,6 +456,8 @@
>  #endif /* CONFIG_NET_DIVERT */
>  };
>  
> +/* 2.6 compatibility */
> +#define SET_NETDEV_DEV(net, pdev) do { } while (0)
>  
>  struct packet_type 
>  {
