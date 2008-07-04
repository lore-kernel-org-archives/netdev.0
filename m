From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 15:42:37 +0100
Message-ID: <1215182557.10393.808.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
	 <1215111362.10393.651.camel@pmac.infradead.org>
	 <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org>	<87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>
	 <486E3622.1000900@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, Theodore Tso <tytso@mit.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: Hannes Reinecke <hare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43646 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbYGDOnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 10:43:00 -0400
In-Reply-To: <486E3622.1000900@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 16:39 +0200, Hannes Reinecke wrote:
> Firmware loading is just a matter of copying the file at the correct
> location (ie /lib/firmware) and with the name the fw loader expects.
> mkinitrd should do it correctly.
> But I wasn't aware that the tg3 has external firmware, so I doubt
> we have any rpm for it.

It doesn't yet; that patch is in linux-next. The firmware is shipped as
part of the kernel source tree, and you currently need to run 'make
firmware_install' to put it in /lib/firmware, although we're looking at
making that easier because apparently having to run 'make
firmware_install' is too hard...

-- 
dwmw2

