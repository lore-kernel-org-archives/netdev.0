From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/21] d80211: pull request
Date: Thu, 24 Aug 2006 09:58:09 +0200
Message-ID: <1156406289.3815.13.camel@ux156>
References: <20060823212316.333159079.midnight@suse.cz>
	 <20060823213033.7eff5eef@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Mohamed Abbas <mabbas@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53427 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750815AbWHXH5y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 03:57:54 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060823213033.7eff5eef@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-23 at 21:30 +0200, Jiri Benc wrote:

> Johannes Berg:
>         d80211:  LED triggers

Yep, as noted, the fix for this is to include some more things in
include/linux/leds.h, which is in -mm:
http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc4/2.6.18-rc4-mm2/broken-out/make-ledsh-include-relevant-headers.patch

>         add nl80211

Yeah, I need to repost a fixed version.

>         make d80211 use nl80211

Ditto, but would appreciate feedback on both of these.

>         d80211:  rework rate control registration
>         d80211:  move out rate control registration code

Thought you wanted to drop them?

johannes
