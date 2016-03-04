From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Fri, 04 Mar 2016 17:32 +0100
Message-ID: <2983219.IrgyuboXyU@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de> <1659125.tHp8H942OG@wuerfel> <1457108303.2651.112.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tilman Schmidt <tilman@imap.cc>,
	Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1457108303.2651.112.camel@tiscali.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 04 March 2016 17:18:23 Paul Bolle wrote:
> [Added Tilman and Christoph.]
> 
> On vr, 2016-03-04 at 16:24 +0100, Arnd Bergmann wrote:
> > I actually did more patches that I ended up not submitting:
> > 
> > * move hisax to staging
> > * remove i4l support from gigaset
> 
> For the record: I have no reason to object a patch that does that. (I'm
> not aware anyone complained when gigaset switched its default from i4l
> to capi. By now all relevant distributions should use our capi driver.)

Ok.

> > * move i4l core to staging
> 
> On a local tree I have two (draft) patches that do some related
> preliminary work:
> - isdnhdlc: move into separate directory
> - mISDN: NETJet: stop selecting ISDN_I4L
> 
> These trivial patches untangle mISDN and i4l. Perhaps you did something
> similar in your "move i4l core to staging".

Yes, I have the same thing. I didn't mention it here as it should
be completely non-controversial.

A third patch moves the capidrv source from drivers/isdn/capi/
into the i4l directory.

> > Any thoughts on this? If you like, I can send those too.
> 
> For my part I'm surprised that anyone is still using it. But apparently
> the hardware that required commit 19cebbcb04c8 and 3460baa62068  (which
> I'm unfamiliar with) is still operational. And since there never has
> been, as far as I know, a global i4l to capi migration nor a global i4l
> (and capi) to mISDN migration it might be that some people are stuck on
> i4l drivers for their hardware. Perhaps that explains Cristoph's
> commits.

My understanding is that it's not about the hardware, and that all
devices that people actually use with hisax should also with with
mISDN.

Instead, the only argument I've heard about keeping i4l and hisax
around (indefinitely) is that existing user space tools are written
for i4l and not ported to mISDN. They work fine with CAPI drivers
using capidrv.ko, but there is no i4l emulation on top of mISDN.

	Arnd
