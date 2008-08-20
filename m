From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Wed, 20 Aug 2008 19:16:57 +0200
Message-ID: <1219252617.7591.350.camel@violet.holtmann.net>
References: <s5h3akzwtki.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Johannes Berg <johannes@sipsolutions.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37612 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbYHTRQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:16:53 -0400
In-Reply-To: <s5h3akzwtki.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

> I found that CONFIG_KMOD was already removed in linux-next tree.
> This seems to result in many breakages.  For example, I cannot mount a
> FAT device automatically because of failure of automatic loading of
> nls modules.
> 
> My particular problem would be fixed by the patch below, but I found
> CONFIG_KMOD is still referred in many places.

I am happy to fix the net/bluetooth/ part, you someone has to put out a
guideline how this should be fixed.

Regards

Marcel


