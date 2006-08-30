From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Wed, 30 Aug 2006 09:01:15 -0700
Message-ID: <20060830160115.GB18041@instant802.com>
References: <20060822173241.313859000@devicescape.com> <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156> <uwt8sww6z.fsf@devicescape.com> <1156836657.3788.5.camel@ux156> <20060829114515.GA29669@tuxdriver.com> <20060829183947.GJ1701@instant802.com> <1156922781.4013.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-83.dex002.intermedia.net ([64.78.20.216]:59099 "EHLO
	dhost002-83.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751102AbWH3QBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 12:01:23 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156922781.4013.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 09:26:21AM +0200, Johannes Berg wrote:
> On Tue, 2006-08-29 at 11:39 -0700, Jouni Malinen wrote:
> 
> > What would be the preferred way of doing the conversion here? I think I
> > would prefer to get the radar detection code in as-is and then move all
> > the messages to use a new mechanism as one change once that mechanism
> > becomes available.
> 
> I suppose that depends on how quickly you want these things :) nl80211
> is there for review and I suppose if a bunch of people actually build
> things on top of it we can merge it. As it stands, we could merge it and
> then start building too, if a few more people review it maybe.

Well, it would be nice to get these in quite soon. I know that the
current mechanism works since it has been used for years, but if the
netlink-based solution is considered stable and working and unlikely to
require major changes soon, I don't have anything against using it here.

> > hostapd connection uses number of these frames which are actually not
> > fake management frames, but just frames with different "pseudo header"
> > on the management interface. You can search for ieee80211_msg_ types to
> > see the different types of status messages that are used.
> 
> Yeah, I know. Does anyone else use these or can we simply drop this
> after conversion?

Once there is mechanism to replace all the current functionality, I
would just drop it. There is some meta information, like signal
strength, in the header, so this does not only include event
notifications, but also additional data for frames.

-- 
Jouni Malinen                                            PGP id EFC895FA
