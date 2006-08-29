From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Tue, 29 Aug 2006 09:30:57 +0200
Message-ID: <1156836657.3788.5.camel@ux156>
References: <20060822173241.313859000@devicescape.com>
	 <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156>
	 <uwt8sww6z.fsf@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46527 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932174AbWH2HbK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 03:31:10 -0400
To: Elliot Schwartz <elliot@devicescape.com>
In-Reply-To: <uwt8sww6z.fsf@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Elliot,

Thanks for the explanation.


> Radar is initially detected by the low-level radio driver.  Userspace
> gets notified of radar via calls to ieee80211_radar_status, which
> generates a "fake" management frame with a struct ieee80211_radar_info
> in it.  Userspace is then responsible for handling the resultant
> activities, such as stopping transmission on that channel, selecting
> another channel, sending out channel switch announcements, changing
> channels, and remembering to block use of the old channel for the
> required time.

I think that would warrant a new netlink multicast group and doing over
nl80211 to start with ;) Inserting fake management frames into the mgt
interface sounds pretty weird to me.

johannes
