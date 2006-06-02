From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] softmac: Fix handling of authentication failure
Date: Fri, 2 Jun 2006 08:04:44 -0400
Message-ID: <20060602120439.GA14289@tuxdriver.com>
References: <20060601143722.D0B2C89CF47@zog.reactivated.net> <447FA5B5.8020707@lwfinger.net> <44800E74.9070605@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:16392 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751197AbWFBMFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 08:05:08 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <44800E74.9070605@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 11:09:56AM +0100, Daniel Drake wrote:
> Larry Finger wrote:
> >This statement fails to compile on my system using Linus' tree, because 
> >ieee80211softmac_disassoc needs a second argument - the reason. It seems 
> >as if WLAN_REASON_PREV_AUTH_NOT_VALID would be appropriate.
> 
> Thanks for pointing that out. This patch depends on a patch titled 
> "softmac: deauthentication implies deassociation" which is apparently 
> not present in Linus' tree.

That patch is in the upstream branch (also available in the master
branch) of wireless-2.6, which is probably what anyone doing wireless
patches should(*) be using.

The approved release process only allows for non-bugfix patches
in the first two weeks after a Linus blesses a new kernel release.
After that only bugfixes are allowed, with non-bugfix patches getting
queued for the next merge window.  The upstream branch represents
that queue of patches.

Hth!

John

(*) The exception being those workign on Devicescape-related patches,
who should be working off the master branch of wireless-dev.
-- 
John W. Linville
linville@tuxdriver.com
