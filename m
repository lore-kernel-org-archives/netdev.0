From: Dmitry Torokhov <dtor@insightbb.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for =?utf-8?q?fullmac=09cards?=
Date: Fri, 17 Nov 2006 00:42:53 -0500
Message-ID: <200611170042.55404.dtor@insightbb.com>
References: <200610031457.33215.chunkeey@web.de> <43e72e890611091516r3362945dm715276f0841ad366@mail.gmail.com> <1163169740.2662.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	"chunkeey@web.de" <chunkeey@web.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:12695 "EHLO
	asav12.insightbb.com") by vger.kernel.org with ESMTP
	id S1424773AbWKQFm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 00:42:57 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1163169740.2662.6.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 10 November 2006 09:42, Dan Williams wrote:
> On Thu, 2006-11-09 at 18:16 -0500, Luis R. Rodriguez wrote:
> > On 11/9/06, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> > > On 11/9/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > > Am Mittwoch, 8. November 2006 01:39 schrieben Sie:
> > > > > On Fri, Nov 03, 2006 at 01:41:46PM -0500, Luis R. Rodriguez wrote:
> > > > > > On 11/3/06, chunkeey@web.de <chunkeey@web.de> wrote:
> > > > > > >yes, especially mgt_commit_list caused alot headaches, until I removed
> > > > > > >DOT11_OID_PSM from the cache list.
> > > > > > >Now, I can "hammer" it with ping -f for hours.
> > > > > >
> > > > > > nice, perhaps that's been the culprit all along... going to dig to see
> > > > > > if I find a fullmac prism card. Will like to get this merged in.
> > > > >
> > > > > Any resolution on this?
> > > >
> > > > no replies.
> > > > Seems like it works for just fine for everybody. ;)
> > >
> > > I found a card, I just need time to test it. Dan didn't you say you
> > > ran into issues with the patch on your card?
> 
> No, more that my card doesn't successfully associate at all even
> _without_ the patch on unencrypted or WEP APs; I just can't test it,
> since my card seems to be broken...
>

FWIW I applied the patch to tonight pull form Linus's tree and my card
stopped associating with my AP (WEP128, Shared key). It only associated
with my neighbour router which is running without encryption.

-- 
Dmitry
