From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 10:33:44 -0700
Message-ID: <20060928173344.GE9615@instant802.com>
References: <200609271726.34305.mb@bu3sch.de> <200609281643.04631.mb@bu3sch.de> <1159455169.2642.30.camel@localhost.localdomain> <200609281713.21082.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-91.dex002.intermedia.net ([64.78.21.115]:9171 "EHLO
	dhost002-91.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030276AbWI1Rdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:33:54 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609281713.21082.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 05:13:20PM +0200, Michael Buesch wrote:
> On Thursday 28 September 2006 16:52, Dan Williams wrote:
> > As a counterpoint, does every developer _really_ want to run
> > wpa_supplicant just to use a WEP-encrypted connection where you may
> > occasionally get kicked off?
> 
> I think that's the way we want to take. Even for unencrypted networks,
> probably. We want as much as possible of the high level MAC
> implementation in userspace. Remember the summit and Simon's talk?
> It was a good talk and made a lot of sense.

I don't know whether every developer wants to run a userspace tool for
that, but taken into account that I'm planning on focusing on the MLME
code in wpa_supplicant instead of fine tuning similar code in kernel, it
should be quite obvious what I would be voting for ;-).

> This userspace implementation should probably renamed from wpa_supplicant
> to wireless_supplicant or whatever.

Yeah.. wpa_supplicant does not really describe the exact set of
functionality in the program. Though, I'm not planning on renaming it
just for the sake of having a better name. Then again, there are plans
on merging (with build time options) wpa_supplicant and hostapd
functionality, so there is a good point for renaming the end result to
something else. At this point, it shouldn't have "supplicant" in the name
either since it will be possible to include both supplicant and
authenticator functionality into the same program (e.g., for IEEE
802.11i IBSS).

-- 
Jouni Malinen                                            PGP id EFC895FA
