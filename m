From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH v3] d80211: Add control structure for beacontemplates
Date: Thu, 8 Feb 2007 19:24:17 +0100
Message-ID: <20070208192417.3f155411@griffin.suse.cz>
References: <200702061704.00190.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	Linux Wireless <linux-wireless@vger.kernel.org>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:37626 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750871AbXBHSYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 13:24:18 -0500
In-Reply-To: <200702061704.00190.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Feb 2007 17:03:59 +0100, Ivo van Doorn wrote:
> Previous send v2 had a null pointer error in it.
> 
> When rt2500usb and rt73usb will start using beacontemplates,
> they would also need a control structure to be passed along to
> correctly set the tx parameters.
> This patch will add a ieee80211_tx_control pointer to the
> ieee80211_if_init_conf structure. This pointer is only a reference
> to a local variable so drivers will not need to call kfree() on it.

Oh, sorry, this one seems to address my previous comment. Applied,
thanks!

 Jiri


-- 
Jiri Benc
SUSE Labs
