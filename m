From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 09:42:19 -0400
Message-ID: <486E28BB.1030205@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>	<20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<486CC440.9030909@garzik.org>	<Pine.LNX.4.64.0807031353030.11033@blonde.site>	<s5hmykxc3ja.wl%tiwai@suse.de>	<1215177471.10393.753.camel@pmac.infradead.org> <s5hej69lqzk.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	Hugh Dickins <hugh@veritas.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48959 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758772AbYGDNm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 09:42:27 -0400
In-Reply-To: <s5hej69lqzk.wl%tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Takashi Iwai wrote:
> Ah I see.  I thought you implemented the built-in firmware even for
> modules, but apparently it's not.

Correct.


> Is mkinitrd clever enough to put all needed firmware files to initrd
> automatically?  Otherwise this can still break the existing setup...

mkinitrd and similar scripts must be updated, so that drivers that 
worked prior to dwmw2's changes will continue to work after dwmw2's changes.

If you fail to update some script somewhere, then the driver will be 
copied into the initramfs, but not the firmware, with obvious results.

This is not a fail-safe system.

This is an enforced-breakage, flag-day change that will cause a lot of 
additional work for a lot of people.

	Jeff



