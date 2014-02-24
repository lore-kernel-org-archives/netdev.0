From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2014-02-20
Date: Mon, 24 Feb 2014 14:49:33 -0500
Message-ID: <20140224194932.GE24810@tuxdriver.com>
References: <20140220203005.GF3657@tuxdriver.com>
 <20140220.172922.864207706999214682.davem@davemloft.net>
 <53068E22.5050003@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58552 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbaBXUAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 15:00:15 -0500
Content-Disposition: inline
In-Reply-To: <53068E22.5050003@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 05:22:10PM -0600, Larry Finger wrote:
> On 02/20/2014 04:29 PM, David Miller wrote:
> >From: "John W. Linville" <linville@tuxdriver.com>
> >Date: Thu, 20 Feb 2014 15:30:05 -0500
> >
> >>Please pull this batch of wireless updates intended for the 3.15
> >>stream!
> >>
> >>For the mac80211 bits, Johannes says:
> >>
> >>"We have some cleanups and minor fixes as well as userspace API
> >>improvements from a lot of people, extended VHT support for radiota=
p
> >>from Emmanuel, CSA improvements from Andrei, Luca and Michal. I've =
also
> >>included my work on hwsim to make dynamic registration of radios
> >>possible."
> >>
> >>Along with that, we get the usual round of updates to ath9k,
> >>brcmfmac, mwifiex, wcn36xx, and the ti drivers -- nothing particula=
rly
> >>noteworthy, mostly just random updates and refactoring.
> >>
> >>Also included is a pull of the wireless tree, intended to resolve
> >>some potential merge issues.
> >>
> >>Please let me know if there are problems!
> >
> >Pulled, but please address this:
> >
> >drivers/staging/rtl8821ae/rtl8821ae/trx.c: In function =E2=80=98rtl8=
821ae_rx_query_desc=E2=80=99:
> >drivers/staging/rtl8821ae/rtl8821ae/trx.c:619:3: warning: passing ar=
gument 1 of =E2=80=98ieee80211_is_robust_mgmt_frame=E2=80=99 from incom=
patible pointer type [enabled by default]
> >
> >I was going to do the easy transformation to the "_" prefixed varian=
t
> >but noticed that this code doesn't validate the skb length, which is
> >precisely the reason why this routine now takes an skb.
>=20
> David,
>=20
> That staging driver is expected to be deleted in a commit to be
> submitted in about one week. The new one will be in the regular
> wireless tree. The staging version was submitted so that there would
> be a driver in 3.14.
>=20
> I was surprised to see this patch in John's list. It should have
> gone through GregKH. In fact, has has been suppressing all cleanups
> because the better one will be available soon.
>=20
> I suggest that you drop this one now. I will, however, check the new
> source to make sure that the skb length is checked.
>=20
> Thanks,
>=20
> Larry

I'll be reverting that patch in wireless-next -- I goofed by merging
a staging patch in the first place.

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
