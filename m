From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: Thu, 26 Feb 2004 14:22:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226142214.76d35e22.davem@redhat.com>
References: <20040223105359.GA91938@colin2.muc.de>
	<20040223.200101.39143636.yoshfuji@linux-ipv6.org>
	<20040223111659.GB10681@colin2.muc.de>
	<20040223.203843.04073965.yoshfuji@linux-ipv6.org>
	<20040223102613.33838132.davem@redhat.com>
	<20040225211526.74478066.ak@suse.de>
	<20040223133233.71eecc99.davem@redhat.com>
	<20040226194900.GA8230@colin2.muc.de>
	<20040226124245.5b3c77bf.davem@redhat.com>
	<20040226205220.GA29457@colin2.muc.de>
	<20040226220316.GA56782@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, ak@suse.de, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20040226220316.GA56782@colin2.muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 26 Feb 2004 23:03:16 +0100
Andi Kleen <ak@muc.de> wrote:

> > I will test now if your change really fixes the DSL performance problem.
> 
> It seems to, but I guess that was by accident.

Nope, fully intentional.  It should end up doing the same thing your
original patch did, check the send buffer size the pppoe socket gets :)
