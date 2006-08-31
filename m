From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Thu, 31 Aug 2006 09:23:37 +0200
Message-ID: <1157009017.3065.14.camel@ux156>
References: <20060822173241.313859000@devicescape.com>
	 <20060822173419.GF12500@devicescape.com> <1156317906.3629.18.camel@ux156>
	 <uwt8sww6z.fsf@devicescape.com> <1156836657.3788.5.camel@ux156>
	 <20060829114515.GA29669@tuxdriver.com>
	 <20060829183947.GJ1701@instant802.com> <1156922781.4013.13.camel@ux156>
	 <20060830160115.GB18041@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39620 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751032AbWHaHXF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 03:23:05 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060830160115.GB18041@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-30 at 09:01 -0700, Jouni Malinen wrote:

> Well, it would be nice to get these in quite soon. I know that the
> current mechanism works since it has been used for years, but if the
> netlink-based solution is considered stable and working and unlikely to
> require major changes soon, I don't have anything against using it here.

:)
May I ask you to take a look at nl80211 to see if it matches your
expectations/needs? It obviously needs to be expanded and we may want to
add some multicast groups that applications can subscribe to for scan
results/radar detection/management frames/...
What really should be done soon is implementing transmit status
notification for injected packets since injection is already working. I
just happen to not need it at the moment and have a bunch of other
things to do.

> Once there is mechanism to replace all the current functionality, I
> would just drop it. There is some meta information, like signal
> strength, in the header, so this does not only include event
> notifications, but also additional data for frames.

That meta information can be transmitted through other channels too
though :)

johannes
