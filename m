From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac
	cards
Date: Fri, 03 Nov 2006 09:49:22 -0500
Message-ID: <1162565362.2863.1.camel@localhost.localdomain>
References: <200610031457.33215.chunkeey@web.de>
	 <20061017213229.GC32614@tuxdriver.com> <200610291335.07729.chunkeey@web.de>
	 <43e72e890610301217g28d169eeu448944e170153948@mail.gmail.com>
	 <1162310754.3155.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "chunkeey@web.de" <chunkeey@web.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:29616 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1753251AbWKCOsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 09:48:02 -0500
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <1162310754.3155.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-31 at 11:05 -0500, Dan Williams wrote:
> On Mon, 2006-10-30 at 15:17 -0500, Luis R. Rodriguez wrote:
> > On 10/29/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > This patch completes WPA/RSN with TKIP support for all fullmac prism54 cards.
> > > I removed all parts which are not relevant for wpa_supplicant (managed mode).
> > 
> > This is great effort and thanks for it! My only concern with the patch
> > is breaking compatiblity with 2.4 but then again I'm tired of having
> > to keep this compat work up too and soon, after d80211 full force push
> > it may not be possible. So I ACK it.
> 
> I'd like to test it a bit first with my fullmac card before it gets
> committed/added...  But it's great to get some movement on this
> card/driver!

So my prism54 fullmac card appears to be broken, since it refuses to
associate with anything at all, even unencrypted access points.  It
doesn't throw any errors at all, and it appears to be operating
correctly other than not associating.

Is there any way to get more information out of the firmware about what
it's doing?

Dan

> Dan
> 
> >   Luis
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

