From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: freeing an active object
Date: Mon, 07 Dec 2015 13:25:41 +0100
Message-ID: <1449491141.3615.11.camel@tiscali.nl>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
	 <565B4256.6080101@hurleysoftware.com> <565B4844.9020600@imap.cc>
	 <1448828800.2603.17.camel@tiscali.nl> <1448839396.2891.14.camel@tiscali.nl>
	 <1448906497.3546.16.camel@tiscali.nl> <565F8341.7010704@hurleysoftware.com>
	 <1449408690.2515.15.camel@tiscali.nl> <5664545C.90607@imap.cc>
	 <1449432742.2515.20.camel@tiscali.nl> <566550E7.80801@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Tilman Schmidt <tilman@imap.cc>,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566550E7.80801@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Re-added mailinglist that got dropped somehow.]

On ma, 2015-12-07 at 10:27 +0100, Tilman Schmidt wrote:
> Am 06.12.2015 um 21:12 schrieb Paul Bolle:
> > This solution assumes that the struct platform_device is moved out
> > of
> > the struct ser_cardstate, doesn't it? In other words, this is
> > something
> > to do on top of my (draft) patch.
> 
> No, that wasn't my intention. I thought of that solution as an
> alternative, not an increment to your patch.
> 
> > Otherwise we'd still be freeing memory
> > managed through reference counting.
> 
> Now I#m confused. I thought by following Peter's suggestion to put the
> kfree() in the release method we'd avoid just that.

(Your patch compiles just fine.)

Apparently it does, because I can't trigger the WARNING we're discussing
here with your patch applied. I'll have to dive into this stuff again,
because apparently my mental model of what's going on is incomplete at
best.

In the mean time you might want to turn your patch into something that
can actually be applied (with or without my Sign-off or Ack; I don't
care how it finds its way into the tree). Please add add
    Fixes: 2869b23e4b95 ("[PATCH] drivers/isdn/gigaset: new M101 driver (v2)")

(Perhaps with a comment that v2.6.32 needs a trivial context change; I'm
not sure how that needs to be communicated.)

But I'm fine with cobbling together a commit explanation myself if
you're too busy right now.

Thanks,


Paul Bolle
