From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 5 Jul 2008 00:52:15 -0300
Message-ID: <20080705035215.GA15899@khazad-dum.debian.net>
References: <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <20080704235839.GA5649@khazad-dum.debian.net> <Pine.LNX.4.64.0807041742500.13075@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Galibert <galibert@pobox.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Hannes Reinecke <hare@suse.de>, Takashi Iwai <tiwai@suse.de>,
	Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:48539 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbYGEDwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 23:52:20 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807041742500.13075@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Jul 2008, Trent Piepho wrote:
> On Fri, 4 Jul 2008, Henrique de Moraes Holschuh wrote:
> > On Sat, 05 Jul 2008, Olivier Galibert wrote:
> >> Won't that break multiple kernel installs on any binary packaging
> >> system that cares about file collisions?  Multiple kernel rpms
> >> providing the same /lib/firmware files would break things wouldn't
> >> they ?
> >
> > We will probably need per-kernel directories, exactly like what is done for
> > modules.  And since there are (now) both kernel-version-specific, and
> > non-kernel-version-specific firmware, this means the firmware loader should
> > look first on the version-specific directory (say, /lib/firmware/$(uname
> > -r)/), then if not found, on the general directory (/lib/firmware).
> 
> How about /lib/modules/`uname -r`/firmware

I am fine with it, it certainly has a few advantages.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
