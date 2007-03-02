From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: s390 allmodconfig
Date: Fri, 2 Mar 2007 00:25:12 -0800
Message-ID: <20070302002512.bd9bbb80.akpm@linux-foundation.org>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:48933 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932965AbXCBIZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 03:25:52 -0500
In-Reply-To: <20070302001811.b103e2b2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/mac80211/ieee80211_led.c: In function 'ieee80211_led_init':
net/mac80211/ieee80211_led.c:38: error: invalid application of 'sizeof' to incomplete type 'struct led_trigger' 
net/mac80211/ieee80211_led.c:43: error: dereferencing pointer to incomplete type
net/mac80211/ieee80211_led.c:44: warning: implicit declaration of function 'led_trigger_register'
net/mac80211/ieee80211_led.c:49: error: invalid application of 'sizeof' to incomplete type 'struct led_trigger' 
net/mac80211/ieee80211_led.c:54: error: dereferencing pointer to incomplete type
net/mac80211/ieee80211_led.c: In function 'ieee80211_led_exit':
net/mac80211/ieee80211_led.c:64: warning: implicit declaration of function 'led_trigger_unregister'

akpm2:/usr/src/25> grep LED .config
CONFIG_NF_CONNTRACK_ENABLED=m
CONFIG_MAC80211_LEDS=y

Probably related to the Kconfig problems.
