From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 01/18] d80211:  LED triggers
Date: Wed, 23 Aug 2006 20:16:16 +0200
Message-ID: <20060823201616.40214286@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075158.728615077@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10906 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965081AbWHWSQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 14:16:18 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075158.728615077@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:08 +0200, Johannes Berg wrote:
> This patch makes d80211 export LED triggers for rx/tx and introduces
> functions to allow device drivers to query the trigger names for setting
> default triggers. It also cleans up the Makefile LED related stuff.

  CC [M]  net/d80211/ieee80211_led.o
In file included from net/d80211/ieee80211_led.h:9,
                 from net/d80211/ieee80211_led.c:11:
include/linux/leds.h:39: error: field 'node' has incomplete type
include/linux/leds.h:44: error: syntax error before 'rwlock_t'
include/linux/leds.h:44: warning: no semicolon at end of struct or union
include/linux/leds.h:50: error: syntax error before '}' token
include/linux/leds.h:72: error: syntax error before 'rwlock_t'
include/linux/leds.h:72: warning: no semicolon at end of struct or union
include/linux/leds.h:77: error: syntax error before '}' token
net/d80211/ieee80211_led.c: In function 'ieee80211_led_init':
net/d80211/ieee80211_led.c:38: error: invalid application of 'sizeof' to incomplete type 'struct
net/d80211/ieee80211_led.c:43: error: dereferencing pointer to incomplete type
net/d80211/ieee80211_led.c:49: error: invalid application of 'sizeof' to incomplete type 'struct
net/d80211/ieee80211_led.c:54: error: dereferencing pointer to incomplete type
make[2]: *** [net/d80211/ieee80211_led.o] Error 1
make[1]: *** [net/d80211] Error 2
make: *** [net] Error 2


Omitting the patch for now.

 Jiri

-- 
Jiri Benc
SUSE Labs
