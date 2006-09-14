From: Johannes Berg <johannes@sipsolutions.net>
Subject: more nl80211 stuff
Date: Thu, 14 Sep 2006 12:46:52 +0200
Message-ID: <1158230812.2936.46.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:13765 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751141AbWINKqR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 06:46:17 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Last night I thought a bit more about configuration handling with
cfg80211/nl80211 and have refined the original framework to be more
split into cfg80211 and nl80211 stuff.

As a followup, I'll post three patches, the first two are essentially
the original ones respun, while the third one represents my current
thoughts (a bit less I guess) on actual configuration and WE
compatibility.

johannes
