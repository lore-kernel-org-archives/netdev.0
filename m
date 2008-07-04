From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 14:28:32 +0100
Message-ID: <1215178112.10393.765.camel@pmac.infradead.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <s5hmykxc3ja.wl%tiwai@suse.de>
	 <1215177471.10393.753.camel@pmac.infradead.org>
	 <s5hej69lqzk.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hugh Dickins <hugh@veritas.com>, Jeff Garzik <jeff@garzik.org>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37652 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbYGDN2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:28:41 -0400
In-Reply-To: <s5hej69lqzk.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 15:26 +0200, Takashi Iwai wrote:
> Ah I see.  I thought you implemented the built-in firmware even for
> modules, but apparently it's not.

It isn't really necessary. If you can load modules, then you have
userspace. And if you have userspace, you can load firmware too.

> Is mkinitrd clever enough to put all needed firmware files to initrd
> automatically?  Otherwise this can still break the existing setup...

Yes, it's had to be clever enough for that for a long time anyway --
most modern drivers have _only_ the 'request_firmware()' option and
never gave you the choice of building it in. I'm just updating some of
the older drivers to catch up.

-- 
dwmw2

