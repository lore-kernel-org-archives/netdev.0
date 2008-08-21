From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Thu, 21 Aug 2008 03:49:17 +0200
Message-ID: <1219283357.7591.370.camel@violet.holtmann.net>
References: <s5h3akzwtki.wl%tiwai@suse.de>
	 <1219252617.7591.350.camel@violet.holtmann.net>
	 <1219257889.3502.13.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1219257889.3502.13.camel@johannes.berg>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

> > > I found that CONFIG_KMOD was already removed in linux-next tree.
> > > This seems to result in many breakages.  For example, I cannot mount a
> > > FAT device automatically because of failure of automatic loading of
> > > nls modules.
> > > 
> > > My particular problem would be fixed by the patch below, but I found
> > > CONFIG_KMOD is still referred in many places.
> > 
> > I am happy to fix the net/bluetooth/ part, you someone has to put out a
> > guideline how this should be fixed.
> 
> Bluetooth was already part of http://lkml.org/lkml/2008/7/9/144
> 
> Basically, I got rid of CONFIG_KMOD, always enabling it when
> CONFIG_MODULES is defined and making it a dummy no-op inline when not.

I missed the patches, but that happens from time to time. Just looked at
them and they look pretty nice. I like it this way.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
