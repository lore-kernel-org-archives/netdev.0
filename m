From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC 0/3] more power to cfg80211
Date: Mon, 11 Dec 2006 14:03:11 +0100
Message-ID: <20061211140311.503dd4ca@griffin.suse.cz>
References: <1163802439.3392.47.camel@johannes.berg>
	<1163963898.15473.36.camel@johannes.berg>
	<1163979143.9216.14.camel@johannes.berg>
	<20061120201402.76e69e46@griffin.suse.cz>
	<1164223133.5934.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
Received: from styx.suse.cz ([82.119.242.94]:40224 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762887AbWLKNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 08:03:00 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1164223133.5934.19.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Nov 2006 20:18:53 +0100, Johannes Berg wrote:
> The following patches are mostly proof-of-concept code for moving over
> stuff to cfg80211 (like the wiphy thing).
> 
> I've changed net_dev->ieee80211_ptr to be of struct wiphy because it
> allows accessing the wiphy by netdev easily then, and since wireless
> drivers are (after these patches) expected to register with cfg80211
> anyway it doesn't really change much. They need wiphy_priv() then but
> it's tiny.

Sorry for the late answer.

I like the concept and think this is a way to go.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
