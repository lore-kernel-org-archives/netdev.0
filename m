From: Martin Langer <martin-langer@gmx.de>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Tue, 3 Oct 2006 17:12:40 +0200
Message-ID: <20061003151240.GA5367@tuba>
References: <200610021843.20694.mb@bu3sch.de> <200610031358.33760.mb@bu3sch.de> <45227569.6070901@lwfinger.net> <200610031648.04932.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:33166 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S964832AbWJCPMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 11:12:44 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610031648.04932.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 04:48:04PM +0200, Michael Buesch wrote:
> On Tuesday 03 October 2006 16:36, Larry Finger wrote:
> > Michael Buesch wrote:
> > >> kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
> > >>   29:46:18
> > > 
> > > Uhm, which firmware are you running?
> > 
> > The softmac version reports the following (The "loaded" messages are something I'm trying.):
> > 
> > kernel: bcm43xx: Firmware: Microcode "bcm43xx_microcode4.fw" loaded.
> > kernel: bcm43xx: Firmware: PCM "bcm43xx_pcm4.fw" loaded.
> > kernel: bcm43xx: Firmware: InitVals0 "bcm43xx_initval01.fw" loaded.
> > kernel: bcm43xx: Microcode rev 0x123, pl 0x21 (2005-01-22  19:48:06)
> 
> Well, so now you know where the problem is.
> I can't debug this for you ;)

You have to wait some time to get correct values. That was the reason 
why I placed version reading originally after bcm43xx_initialize_irq(), 
because I got strange values if I read the version directly after the 
upload.

Martin 
