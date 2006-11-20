From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/13] d80211: reduce mdev usage, change
	ieee80211_rx_mgmt
Date: Mon, 20 Nov 2006 13:25:06 +0100
Message-ID: <1164025506.2744.32.camel@ux156>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964402.15473.47.camel@johannes.berg>
	 <20061120130859.329993c8@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:29338 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S934115AbWKTMX4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 07:23:56 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061120130859.329993c8@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-11-20 at 13:08 +0100, Jiri Benc wrote:

> offsetof(ieee80211_frame_info, msg_type)? 

Hm, I guess I could do that. I could just zero out the whole struct too
I think.

> But it doesn't matter, this
> is going to go away (hopefully soon) anyway.

Right. If you don't mind I'll leave it as-is assuming that msg_type is
the last field; I'll hopefully be able to subsume this into cfg80211
soonish.

johannes
