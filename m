From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] brcmfmac: support removing AP interfaces with new fw
Date: Wed, 29 Jun 2016 21:57:41 +0200
Message-ID: <CACna6rwQ6s0j5k74p=xAtX7Qe=y11Hivbd0hF2=bksZp6rK9gA@mail.gmail.com>
References: <1466353420-30998-1-git-send-email-zajec5@gmail.com> <1467230067-3302-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467230067-3302-1-git-send-email-zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29 June 2016 at 21:54, Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> This is the latest patchset needed to get brcmfmac working reasonably=
 well
> with BCM4366.
>
> Both patches were already sent as V2 RFC (10 days ago), there were no=
 more
> comments since then and this is the same code as in V2 RFC. I was mos=
tly waiting
> for accepting
> brcmfmac: fix lockup when removing P2P interface after event timeout
> before sending these 2 (because of dependency).
>
> Rafa=C5=82 Mi=C5=82ecki (2):
>   brcmfmac: delete interface directly in code that sent fw request
>   brcmfmac: support removing AP interfaces with "interface_remove"
>
>  .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 39 ++++++++++++=
+++++++++-
>  .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    | 10 ++++--
>  .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |  3 +-
>  3 files changed, 47 insertions(+), 5 deletions(-)

Oops, I just realized get_maintainer.pl didn't pick any ppl/ML for
this cover letter. Added them now.

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
