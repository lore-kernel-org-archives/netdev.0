From: Jes Sorensen <jes@trained-monkey.org>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: 12 Jun 2003 13:05:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3n0gnxm48.fsf@trained-monkey.org>
References: <20030611144249.7cd63c1c.shemminger@osdl.org>
	<m3y90845nu.fsf@trained-monkey.org>
	<20030611.210445.21901735.davem@redhat.com>
	<3EE81263.4040205@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <3EE81263.4040205@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Stephen" == Stephen Hemminger <shemminger@osdl.org> writes:

Stephen> The funny thing is this alloc_etherdev patch did not change
Stephen> the compatiablity one bit.  Just for grins, took the 2.5
Stephen> driver back into the 2.4.18 and it doesn't build.  The
Stephen> problem is it doesn't know what irqreturn_t is.  The enclosed
Stephen> cribbed from atm/he.c fixes that, but it still redefines
Stephen> local_irq_save etc.

Hi Stephen,

I went back and looked at the comment in 2.4 for when alloc_etherdev
was introduced, but clearly I got the mapping of this to the 2.4.x
release dates wrong. That was my bad.

As for local_irq_save() those patches will still be needed if they are
not present in 2.4.17 (I think this is probably a reasonable cut-off
release), if it's in 2.4.17+ I'll agree we can pull it.

But the irqreturn_t compat stuff still needs to go in since it's
clearly not going to be present in 2.4.18 etc.

Cheers,
Jes
