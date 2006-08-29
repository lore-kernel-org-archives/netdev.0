From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Tue, 29 Aug 2006 07:45:23 -0400
Message-ID: <20060829114515.GA29669@tuxdriver.com>
References: <20060822173241.313859000@devicescape.com> <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156> <uwt8sww6z.fsf@devicescape.com> <1156836657.3788.5.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:49668 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964954AbWH2Lq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 07:46:29 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156836657.3788.5.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 09:30:57AM +0200, Johannes Berg wrote:

> > Radar is initially detected by the low-level radio driver.  Userspace
> > gets notified of radar via calls to ieee80211_radar_status, which
> > generates a "fake" management frame with a struct ieee80211_radar_info
> > in it.  Userspace is then responsible for handling the resultant
> > activities, such as stopping transmission on that channel, selecting
> > another channel, sending out channel switch announcements, changing
> > channels, and remembering to block use of the old channel for the
> > required time.
> 
> I think that would warrant a new netlink multicast group and doing over
> nl80211 to start with ;) Inserting fake management frames into the mgt
> interface sounds pretty weird to me.

I concur -- inserting frames is a neat hack, but not the preferred
way for the long haul.

John
-- 
John W. Linville
linville@tuxdriver.com
