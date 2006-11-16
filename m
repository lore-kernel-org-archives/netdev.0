From: Jouni Malinen <jkm@devicescape.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Thu, 16 Nov 2006 09:40:53 -0800
Message-ID: <20061116174053.GA7531@instant802.com>
References: <1161678908.2840.12.camel@ux156> <1161679134.7258.6.camel@devlinux-hong> <1161681021.2840.23.camel@ux156> <1161764889.8668.13.camel@devlinux-hong> <1161766245.2767.17.camel@ux156> <1163470978.7789.31.camel@devlinux-hong> <1163607901.2705.53.camel@ux156> <1163670762.2763.19.camel@ux156> <20061116172131.GA7404@instant802.com> <1163698700.3392.7.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hong Liu <hong.liu@intel.com>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-95.dex002.intermedia.net ([64.78.19.86]:25566 "EHLO
	dhost002-95.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1031119AbWKPRqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 12:46:46 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163698700.3392.7.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 16, 2006 at 06:38:20PM +0100, Johannes Berg wrote:

> Oh, good point. Will need to think about this more. But right now, if
> that MMIC flag is set (i.e. hw does MMIC), we still do MMIC for
> fragmented frames. And there's actually a bug here I think: if hw does
> MMIC, how can the driver tell not to do it on those frames it's getting
> as fragments?

It's been awhile since I working on this part, but if I remember
correctly, this can be done easily by the driver behaving different
based on the frame being fragmented or not (it is fragmented if MoreFrag
flag is set or seq# != 0). That's the way it was done with hardware
designs that allow full TKIP hwaccel for MSDUs that are not fragmented,
but require software implementation of Michael MIC if MSDU is
fragmented.

-- 
Jouni Malinen                                            PGP id EFC895FA
