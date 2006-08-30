From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Wed, 30 Aug 2006 09:26:21 +0200
Message-ID: <1156922781.4013.13.camel@ux156>
References: <20060822173241.313859000@devicescape.com>
	 <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156>
	 <uwt8sww6z.fsf@devicescape.com> <1156836657.3788.5.camel@ux156>
	 <20060829114515.GA29669@tuxdriver.com>
	 <20060829183947.GJ1701@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57498 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750864AbWH3H0a
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 03:26:30 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060829183947.GJ1701@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-29 at 11:39 -0700, Jouni Malinen wrote:

> What would be the preferred way of doing the conversion here? I think I
> would prefer to get the radar detection code in as-is and then move all
> the messages to use a new mechanism as one change once that mechanism
> becomes available.

I suppose that depends on how quickly you want these things :) nl80211
is there for review and I suppose if a bunch of people actually build
things on top of it we can merge it. As it stands, we could merge it and
then start building too, if a few more people review it maybe.

> hostapd connection uses number of these frames which are actually not
> fake management frames, but just frames with different "pseudo header"
> on the management interface. You can search for ieee80211_msg_ types to
> see the different types of status messages that are used.

Yeah, I know. Does anyone else use these or can we simply drop this
after conversion?

johannes
