From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Tue, 25 May 2004 10:51:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525105101.2da85469.davem@redhat.com>
References: <20040524072657.GC27177@sgi.com>
	<20040524004045.58b3eb44.davem@redhat.com>
	<20040524080431.GD27177@sgi.com>
	<20040524100634.1349295d.davem@redhat.com>
	<20040525010434.GA31134@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040525010434.GA31134@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 May 2004 11:04:34 +1000
Greg Banks <gnb@sgi.com> wrote:

> I agree that this code appears to implictly rely on always getting
> complete send ring updates.

Greg, did you see Micahel Chan's response?  A Broadcom engineer
is telling us "the hardware does not ACK partial TX packets."

I can't think of a more reliable source for this kind of information,
can you?  Given this, it doesn't matter all of the difference you
mention between the tg3 and bcm5700 driver, the hardware simply is
never supposed to do this as stated by somehow who has access to
the actual hardware engineers. :-)

I don't argue that you aren't seeing something strange, but perhaps
that is due to corruption occuring elsewhere, or perhaps something
peculiar about your system hardware (perhaps the PCI controller
mis-orders PCI transactions or something silly like that)?

Have you reproduced this on some system other than these huge SGI
ones?
