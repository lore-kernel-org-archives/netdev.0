From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 08:45:15 -0700
Message-ID: <20060928154515.GA9615@instant802.com>
References: <ef3s4u$or5$3@sea.gmane.org> <1159365434.451a833ae7728@imp3-g19.free.fr> <1159365316.2698.40.camel@ux156> <200609281735.17616.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, castet.matthieu@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-41.dex002.intermedia.net ([64.78.21.130]:12496 "EHLO
	dhost002-41.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S965058AbWI1PpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:45:22 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609281735.17616.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 05:35:17PM +0200, Michael Buesch wrote:
> On Wednesday 27 September 2006 15:55, Johannes Berg wrote:
> > On Wed, 2006-09-27 at 15:57 +0200, castet.matthieu@free.fr wrote:
> > > Also I wonder what should be the max mtu.
> > 
> > 2304, I think, as that's
> > synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */
> > 
> > But maybe I'm interpreting the spec wrongly?
> 
> Yes, I think so. ;)
> 
> I am pretty sure this is the maximum _fragment_ size.
> But each packet (which max size is defined by the MTU) can
> be fragmented. I don't know if there's a limit on the max
> number of frags.

No it's not. How about reading the standard.. ;-) Take a look at how
MSDU and MPDU are defined.. MSDU can be fragmented into smaller MPDUs,
but the limit here is indeed for MSDU, not MPDU. In other words,
fragmentation in IEEE 802.11 is different from fragmentation in IP and
it is also used for different purpose.

-- 
Jouni Malinen                                            PGP id EFC895FA
