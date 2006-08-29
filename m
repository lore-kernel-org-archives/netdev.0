From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Tue, 29 Aug 2006 11:39:47 -0700
Message-ID: <20060829183947.GJ1701@instant802.com>
References: <20060822173241.313859000@devicescape.com> <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156> <uwt8sww6z.fsf@devicescape.com> <1156836657.3788.5.camel@ux156> <20060829114515.GA29669@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-4.dex002.intermedia.net ([64.78.21.18]:11364 "EHLO
	dhost002-4.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965254AbWH2Sjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 14:39:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060829114515.GA29669@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 07:45:23AM -0400, John W. Linville wrote:
> On Tue, Aug 29, 2006 at 09:30:57AM +0200, Johannes Berg wrote:

> > I think that would warrant a new netlink multicast group and doing over
> > nl80211 to start with ;) Inserting fake management frames into the mgt
> > interface sounds pretty weird to me.
> 
> I concur -- inserting frames is a neat hack, but not the preferred
> way for the long haul.

What would be the preferred way of doing the conversion here? I think I
would prefer to get the radar detection code in as-is and then move all
the messages to use a new mechanism as one change once that mechanism
becomes available.

hostapd connection uses number of these frames which are actually not
fake management frames, but just frames with different "pseudo header"
on the management interface. You can search for ieee80211_msg_ types to
see the different types of status messages that are used.

-- 
Jouni Malinen                                            PGP id EFC895FA
