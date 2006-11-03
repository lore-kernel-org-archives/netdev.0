From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 3 Nov 2006 13:41:46 -0500
Message-ID: <43e72e890611031041x1e07306cwbb16bcfa0fd782a7@mail.gmail.com>
References: <200610031457.33215.chunkeey@web.de>
	 <1162565362.2863.1.camel@localhost.localdomain>
	 <43e72e890611030806x14745b17q4916b785a7fb5f8e@mail.gmail.com>
	 <200611031912.35525.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Dan Williams" <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:671 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1753445AbWKCSlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 13:41:47 -0500
Received: by ug-out-1314.google.com with SMTP id m3so485757ugc
        for <netdev@vger.kernel.org>; Fri, 03 Nov 2006 10:41:46 -0800 (PST)
To: "chunkeey@web.de" <chunkeey@web.de>
In-Reply-To: <200611031912.35525.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:
> Am Freitag, 3. November 2006 17:06 schrieben Sie:
> > On 11/3/06, Dan Williams <dcbw@redhat.com> wrote:
> > > On Tue, 2006-10-31 at 11:05 -0500, Dan Williams wrote:
> > > > On Mon, 2006-10-30 at 15:17 -0500, Luis R. Rodriguez wrote:
> > > > > On 10/29/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > > > > This patch completes WPA/RSN with TKIP support for all fullmac
> > > > > > prism54 cards. I removed all parts which are not relevant for
> > > > > > wpa_supplicant (managed mode).
> > > > >
> > > > > This is great effort and thanks for it! My only concern with the
> > > > > patch is breaking compatiblity with 2.4 but then again I'm tired of
> > > > > having to keep this compat work up too and soon, after d80211 full
> > > > > force push it may not be possible. So I ACK it.
> > > >
> > > > I'd like to test it a bit first with my fullmac card before it gets
> > > > committed/added...  But it's great to get some movement on this
> > > > card/driver!
> > >
> > > So my prism54 fullmac card appears to be broken, since it refuses to
> > > associate with anything at all, even unencrypted access points.  It
> > > doesn't throw any errors at all, and it appears to be operating
> > > correctly other than not associating.
> >
> > chunkeey, I figured your patch was well tested as you had it sitting
> > there for a while  I gotta find a fullmac working card (most of them
> > broke while debugging) to debug.
> >
> well, it was already tested by:
> Maxi, Dan S., Gabriel, C and "me".
> "The best configuration is: WPA2 with TKIP!"
>
> > > Is there any way to get more information out of the firmware about what
> > > it's doing?
> >
> > The driver supports prism54_get_oid and prism54_set_u32. The list of
> > OIDs available are on isl_oid.h on oid_num_t enum. Just an FYI you if
> > you need to access the *EX OIDs you just need to be in extended mode.
> > Also for WPA you need to be in extended mode. To say the least last
> > the driver was pretty unstable in extended mode last I used worked on
> > it. Dan do you get any funky mgt timeouts on your ring buffer?
> > Anything useful there?
> >
> >   Luis
> yes, especially mgt_commit_list caused alot headaches, until I removed
> DOT11_OID_PSM from the cache list.
> Now, I can "hammer" it with ping -f for hours.

nice, perhaps that's been the culprit all along... going to dig to see
if I find a fullmac prism card. Will like to get this merged in.

  Luis
