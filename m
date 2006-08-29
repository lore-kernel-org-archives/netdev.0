From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Tue, 29 Aug 2006 10:45:31 -0700
Message-ID: <20060829174531.GH1701@instant802.com>
References: <44F3572E.8020506@linux.intel.com> <1156837757.3788.10.camel@ux156> <20060829114915.GB29669@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org,
	jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-12.dex002.intermedia.net ([64.78.21.79]:29991 "EHLO
	dhost002-12.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965184AbWH2Rpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 13:45:42 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060829114915.GB29669@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 07:49:22AM -0400, John W. Linville wrote:
> On Tue, Aug 29, 2006 at 09:49:17AM +0200, Johannes Berg wrote:
> > I intend to kill the nick command with nl80211 since it seems to be
> > useless. Any objections?
> 
> I can't defend it myself, but I have heard of people using it.
> I think some of the distro's init scripts might set it as well?
> 
> Can anyone defend the practice of setting a nickname for a wireless
> device?

I think that this was added either based on a non-802.11 protocol or
based on a specific hardware/firmware design that had possibility of
configuring a name for the client (to be exchanged with some proprietary
network management protocol as the device name).

After that, this ioctl seems to be just used for binding some arbitrary
data to an interface to help scripts etc. In other words, I don't see
any real use for this from the view point of IEEE 802.11 networks and it
is confusing at best. This may be useful for some setup scripts, but I
would rather hope they would use something else instead.

The only reason for adding nick command would be to maintain backwards
compatibility with some scripts. I do not use any distro configuration
mechanisms for setting up wireless, so I do not know what is currently
being used. I would not add these ioctls into d80211 unless someone can
point out an existing (and widely used) mechanism that depends on these
ioctls being available.

-- 
Jouni Malinen                                            PGP id EFC895FA
