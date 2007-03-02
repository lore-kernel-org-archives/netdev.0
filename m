From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: s390 allmodconfig
Date: Fri, 2 Mar 2007 03:01:43 -0800
Message-ID: <20070302030143.03d26b6c.akpm@linux-foundation.org>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
	<20070302002512.bd9bbb80.akpm@linux-foundation.org>
	<1172831552.11149.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
To: Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53797 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933328AbXCBLCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 06:02:45 -0500
In-Reply-To: <1172831552.11149.19.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 10:32:32 +0000 Richard Purdie <rpurdie@rpsys.net> wrote:

> On Fri, 2007-03-02 at 00:25 -0800, Andrew Morton wrote:
> > net/mac80211/ieee80211_led.c: In function 'ieee80211_led_init':
> > net/mac80211/ieee80211_led.c:38: error: invalid application of 'sizeof' to incomplete type 'struct led_trigger' 
> > net/mac80211/ieee80211_led.c:43: error: dereferencing pointer to incomplete type
> > net/mac80211/ieee80211_led.c:44: warning: implicit declaration of function 'led_trigger_register'
> > net/mac80211/ieee80211_led.c:49: error: invalid application of 'sizeof' to incomplete type 'struct led_trigger' 
> > net/mac80211/ieee80211_led.c:54: error: dereferencing pointer to incomplete type
> > net/mac80211/ieee80211_led.c: In function 'ieee80211_led_exit':
> > net/mac80211/ieee80211_led.c:64: warning: implicit declaration of function 'led_trigger_unregister'
> > 
> > akpm2:/usr/src/25> grep LED .config
> > CONFIG_NF_CONNTRACK_ENABLED=m
> > CONFIG_MAC80211_LEDS=y
> > 
> > Probably related to the Kconfig problems.
> 
> Almost certainly. Someone is building some LED trigger/driver without
> the LED core enabled which is what that Kconfig warning was about.
> 
> Nobody's ever mentioned this driver to me...
> 

It's a mountain of new wireless code in the just-released 2.6.21-rc2-mm1.

