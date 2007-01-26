From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bcm43xx-d80211: Interrogate hardware-enable switch and update LEDs
Date: Thu, 25 Jan 2007 21:44:51 -0500
Message-ID: <20070126024451.GK10282@tuxdriver.com>
References: <459749bb.q8/+AsgXLhurTs3u%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3489 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030719AbXAZDIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 22:08:24 -0500
Content-Disposition: inline
In-Reply-To: <459749bb.q8/+AsgXLhurTs3u%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 30, 2006 at 11:25:15PM -0600, Larry Finger wrote:
> The current bcm43xx driver ignores any wireless-enable switches on mini-PCI
> and mini-PCI-E cards. This patch implements a new routine to interrogate the
> radio hardware enabled bit in the interface, logs the initial state and any
> changes in the switch (if debugging enabled), activates the LED to show the
> state, and changes the periodic work handler to provide 1 second response
> to switch changes and to account for changes in the periodic work specs. It
> also incorporates changes in the LED state that were accepted into mainline
> some time ago.

Larry,

I wanted to merge this, but a slew of changes pulled from Michael
makes this patch fail to apply.  Would you mind refactoring the patch
and resubmitting?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
