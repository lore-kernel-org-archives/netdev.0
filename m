From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 09:13:32 -0700
Message-ID: <20060928161332.GD9615@instant802.com>
References: <ef3s4u$or5$3@sea.gmane.org> <1159365434.451a833ae7728@imp3-g19.free.fr> <1159365316.2698.40.camel@ux156> <200609281735.17616.mb@bu3sch.de> <1159458432.2648.38.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, castet.matthieu@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-33.dex002.intermedia.net ([64.78.21.118]:154 "EHLO
	dhost002-33.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751328AbWI1QNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 12:13:42 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159458432.2648.38.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 05:47:12PM +0200, Johannes Berg wrote:
> On Thu, 2006-09-28 at 17:35 +0200, Michael Buesch wrote:
> 
> > I am pretty sure this is the maximum _fragment_ size.
> 
> But then why does it talk of MPDU and MSDU?

Maybe because your understanding is closer to what the standard says..
;-)

> IOW, I read it as an MSDU is the data that is supposed to be transmitted
> over the link and that can be at most 2304 bytes long, and then it may
> be fragmented or not and is then copied into (an) MPDU(s).

Yes.

> > But each packet (which max size is defined by the MTU) can
> > be fragmented. I don't know if there's a limit on the max
> > number of frags.
> 
> There's only a 4 bit fragment counter ;) However, see above.

And 4 bits is quite enough for sending the maximum number of fragments
which is currently about 10 (256 octet min frag len and 2304 max MSDU
len with some extra needed to cover the extra header in each fragment).

-- 
Jouni Malinen                                            PGP id EFC895FA
