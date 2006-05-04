From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Thu, 4 May 2006 14:33:55 +0200
Message-ID: <20060504143355.7bbfef35@griffin.suse.cz>
References: <200605032105.53694.mb@bu3sch.de>
	<20060504111140.050c3e2f@griffin.suse.cz>
	<1146745340.1137.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21214 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932279AbWEDMd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 08:33:57 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1146745340.1137.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 04 May 2006 14:22:20 +0200, Johannes Berg wrote:
> Probably. And yes, it should still work since stop>start at all times.

Are you sure you can guarantee that stop > start when these values come
from hardware you don't have specification for?

> Yes, if the card has been up for like 459148 years or has been reset to
> an unbelievably high value. Remember, it's a 64 bit counter.

TSF is set to a value sent by an AP. Is there anything that prevents
that AP to send you e.g. 0xfffffffffffff0?

 Jiri

-- 
Jiri Benc
SUSE Labs
