From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 01/18] d80211:  LED triggers
Date: Thu, 24 Aug 2006 09:03:38 +0200
Message-ID: <1156403018.3815.4.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075158.728615077@sipsolutions.net>
	 <20060823201616.40214286@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:52681 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030357AbWHXHDR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 03:03:17 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060823201616.40214286@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-23 at 20:16 +0200, Jiri Benc wrote:

>   CC [M]  net/d80211/ieee80211_led.o
> In file included from net/d80211/ieee80211_led.h:9,
>                  from net/d80211/ieee80211_led.c:11:
> include/linux/leds.h:39: error: field 'node' has incomplete type
> include/linux/leds.h:44: error: syntax error before 'rwlock_t'

Oh right, forgot about that. Please queue, the fix for this is in -mm,
include/linux/leds.h isn't including all files it requires.

johannes
