From: Tim Shepard <shep@alum.mit.edu>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Thu, 03 Mar 2016 21:48:40 -0500
Message-ID: <E1abfnE-0000VS-00@www.xplot.org>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
Cc: linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	dave.taht@gmail.com, emmanuel.grumbach@intel.com, nbd@openwrt.org,
	andrewmcgr@google.com, apenwarr@google.com
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.xplot.org ([66.92.66.146]:35172 "EHLO www.xplot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617AbcCDCsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 21:48:31 -0500
In-reply-to: Your message of Fri, 26 Feb 2016 14:09:23 +0100.
             <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




If you want to try out Michal's patch you'll need a mac80211 driver
that uses the new intermediate queues.

I just submitted a PATCH RFC/RFT to modify ath9k to use the new
intermediate software queues.  There are very few (zero or close to
zero) drivers in linux which do that, and Michal's patch does not do
anything at all unless your driver uses the new intermediate software
queues.

See If you want to try out Michal's patch you'll need a mac80211 driver
that uses the new intermediate queues.

I just submitted a PATCH RFC/RFT to modify ath9k to use the new
intermediate software queues.  There are very few (zero or close to
zero) drivers in linux which do that, and Michal's patch does not do
anything at all unless your driver uses the new intermediate software
queues.

See my post from a few hours ago with subject:

    [PATCH RFC/RFT 0/2] ath9k: use mac80211 intermediate software queues


(I am interested in knowing what other mac80211 drivers have been
 modified to use the mac80211 intermediate software queues.   I know
 Michal mentioned he has patches for ath10k that are not yet released,
 and I know Felix is finishing up the mt76 driver which uses them.)


			-Tim Shepard
			 shep@alum.mit.edu
