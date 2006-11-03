From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] bcm43xx: Drain TX status before starting IRQs
Date: Fri, 3 Nov 2006 08:56:27 -0800
Message-ID: <20061103165627.GC16894@instant802.com>
References: <200610191729.35402.mb@bu3sch.de> <45498633.7040808@lwfinger.net> <1162457146.3241.13.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-48.dex002.intermedia.net ([64.78.21.144]:46193 "EHLO
	dhost002-48.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1753367AbWKCQ5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 11:57:00 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1162457146.3241.13.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 09:45:46AM +0100, Johannes Berg wrote:
> On Wed, 2006-11-01 at 23:46 -0600, Larry Finger wrote:
> > Has anyone used this patch, particularly with WPA encryption? When I try it, wpa_supplicant 
> > immediately uses 90+% of the cpu and never actually authenticates with my AP. I wonder if it is 
> > something with my system.

What does wpa_supplicant do here? Have you looked at the debug log? Is
it in some kind of busy loop doing something?

> Unless wpa supplicant is stupid [1] this cannot cause it any problems.
> 
> johannes
> 
> [1] by that, I mean sending out frames, turning off and on the
> interface, and then hoping to get a transmit status for frames sent
> before off/on cycle.

wpa_supplicant does not receive or query TX status (at least yet; in the
user space MLME case this is likely to change at some point).

-- 
Jouni Malinen                                            PGP id EFC895FA
