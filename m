From: Andrew Morton <akpm@osdl.org>
Subject: Re: netif_poll_disable() hangs
Date: Mon, 8 Sep 2003 00:29:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908002914.737122a9.akpm@osdl.org>
References: <20030907232145.6ec197fd.akpm@osdl.org>
	<3F5C2D1A.5050500@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F5C2D1A.5050500@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> Andrew Morton wrote:
> > Very simple:
> > 
> > 	ifup eth0
> > 	ifdown eth0
> > 	ifup eth0
> > 	ifdown eth0	<- hangs in dev_close -> netif_poll_disable()
> > 
> > 
> > Because the first close sets __LINK_STATE_RX_SCHED and nothing ever clears
> > it.  
> 
> 
> Weird.  Looking at older 2.4 and 2.6, the bit has always been set that way.

2.4 does test_bit, 2.6 does test_and_set_bit.
