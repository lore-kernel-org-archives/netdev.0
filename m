From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 0/8] Drop support for Renesas H8/300 architecture
Date: Tue, 3 Sep 2013 13:59:22 -0700
Message-ID: <20130903205922.GA3372@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
 <52254F11.8070601@gmail.com>
 <522556D8.803@roeck-us.net>
 <52255CF1.6020700@gmail.com>
 <20130903193938.GB13318@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen Gang F T <chen.gang.flying.transformer@gmail.com>,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org, linux-watchdog@vger.kernel.org,
	Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Linus Walleij <linus.walleij@linaro.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130903193938.GB13318@ZenIV.linux.org.uk>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 03, 2013 at 08:39:38PM +0100, Al Viro wrote:
> On Tue, Sep 03, 2013 at 11:52:17AM +0800, Chen Gang F T wrote:
> 
> >   extreme sample: let 'kernel code style' and 'gcc code style' in one file, that will make the code very ugly.
> 
> gcc style will make any code very ugly, no matter what (if anything) else is
> in the same file...
> 
> [digs out the ports history table]
> x86:		0.01			[alive]
> 	i386:		0.01..2.6.24-rc1 [folded into x86]
> 	x86_64:		2.5.5-pre1..2.6.24-rc1 [folded into x86]
> 	x86:		2.6.24-rc1		[alive]
> alpha:		1.1.67			[alive]
> sparc:		1.1.77			[alive]
> 	sparc64:	2.1.19..2.6.28 [folded into sparc]
> mips:		1.1.82			[alive]
> 	mips64:		2.3.48-pre2..2.6.0-test2 [folded into mips]
> powerpc:	1.3.45			[alive]
> 	ppc:    	1.3.45..2.6.26 [folded into powerpc]
> 	ppc64:		2.5.5..2.6.15-rc1 [folded into powerpc]
> 	powerpc:	2.6.15-rc1		[alive]
> m68k:		1.3.94			[alive]
> 	m68knommu:	2.5.46..2.6.38 [folded into m68k]
> arm:		2.1.80			[alive]
> 	arm26:		2.5.71..2.6.23-rc2 [gone]
> 	arm64:		3.7-rc1			[alive][might eventually fold]
> sh:		2.3.16			[alive]
> 	sh64:		2.6.8-rc1..2.6.24 [folded into sh, nearly dead there]
> ia64:		2.3.43-pre1		[alive]
> s390:		2.3.99pre8		[alive]
> 	s390x:		2.5.0..2.5.67 [folded into s390]
> parisc:		2.4.0-test12		[alive]
> cris:		2.5.0			[alive]
> um:		2.5.35			[alive]
> v850:		2.5.46..2.6.26 [gone]
> h8300:		2.5.68			[moderately responsive]
> m32r:		2.6.9-rc3		[alive]
> frv:		2.6.11-rc1		[alive]
> xtensa:		2.6.13-rc1		[alive]
> avr32:		2.6.19-rc1		[alive]
> blackfin:	2.6.22-rc1		[alive]
> mn10300:	2.6.25-rc1		[alive]
> microblaze:	2.6.30-rc2		[alive]
> score:		2.6.32-rc1		[abandoned][cloned off mips]
> tile:		2.6.36-rc1		[alive]
> unicore32:	2.6.39-rc1		[alive][cloned off arm]
> openrisc:	3.1-rc1			[alive]
> hexagon:	3.2-rc1			[alive]
> c6x:		3.3-rc1			[alive]
> arc:		3.9-rc1			[alive]
> metag:		3.9-rc1			[alive]
> 
> Frankly, I would've expected score and lefotvers of sh64 (aka sh5) to be
> the first against the wall - h8300 was a bit surprising...
> 

Great summary.

There seemed to be a consensus to remove h8300, at least so far and sufficiently
enough for me to ask Stephen to add the removal branch to linux-next.
We'll see if that triggers any further responses.

With score, I am not entirely sure. I got one Ack for the removal, but
on the other side the score maintainers came back and claimed they would
still support it. We'll see if anything changes in practice. I am still
not sure if I should ask for the removal branch to be added to linux-next.
Frankly I thought I might jump the gun here more than with h8300.

Either case, what to ultimately do with those two architectures will be
up to the community to decide.

Guenter
