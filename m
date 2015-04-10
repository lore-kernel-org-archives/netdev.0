From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/3 net-next] e1000: Allocate
 pm_qos_req as needed
Date: Fri, 10 Apr 2015 01:58:07 -0700
Message-ID: <1428656287.2729.83.camel@jtkirshe-mobl>
References: <cover.1428622095.git.tgraf@suug.ch>
	 <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>
	 <1428624503.2729.55.camel@jtkirshe-mobl>
	 <1428640539.2729.67.camel@jtkirshe-mobl> <55278377.8030505@iogearbox.net>
	 <20150410084856.GC23070@casper.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cAV6ejsuBHu3mplXIwGy"
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3523 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753104AbbDJI6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 04:58:31 -0400
In-Reply-To: <20150410084856.GC23070@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cAV6ejsuBHu3mplXIwGy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 09:48 +0100, Thomas Graf wrote:
> On 04/10/15 at 10:01am, Daniel Borkmann wrote:
> > On 04/10/2015 06:35 AM, Jeff Kirsher wrote:
> > >On Thu, 2015-04-09 at 17:08 -0700, Jeff Kirsher wrote:
> > >>On Fri, 2015-04-10 at 01:43 +0200, Thomas Graf wrote:
> > >>>e1000 is the only driver requiring pm_qos_req, instead of causing
> > >>>every device to waste up to 240 bytes. Allocate it for the specific
> > >>>driver.
> > >>>
> > >>>Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > >>>---
> > >>>  drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++----
> > >>>  include/linux/netdevice.h                  |  2 +-
> > >>>  2 files changed, 12 insertions(+), 5 deletions(-)
> > >>
> > >>Small nitpick, it is e1000e not e1000 that you are modifying.
> > >
> > >So other than the patch title and description referencing e1000 instea=
d
> > >of e1000e, patch looks fine.
> > >
> > >Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >=20
> > Thanks for working towards reducing struct net_device, that's awesome!
> >=20
> > Wrt this patch, I'm wondering if that couldn't be pushed down into
> > struct e1000_adapter entirely?
>=20
> Sure, since I need to respin this anyway. Jeff are you OK with that?

I am trying to think why we did not do it earlier, but I am not coming
up with anything at the moment.  So, go ahead.

In the meantime, I will talk with Bruce Allan tomorrow to see if he
remembers why we did not do it.

--=-cAV6ejsuBHu3mplXIwGy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJ5CfAAoJEOVv75VaS+3ODNoQAIQJi9dDw1sjQMx/mZrc9nSK
Z609bQRpCjrgcDV2PGbYk7nkoKLuvG4mCPOavgMRTtrQ9QRxAIYiI0XVUJsRd7B8
rQSNDReBlUOKobo+U+6fDao7D5WBJH7q5pfyABTHQcc1S0NqrXPbOw2WjrAGMTtB
nn9EN47VshG1fLRmf06ic2++0PPoJtRtXOyKC1F8bFpREDZttabETpIzLSgSsR8w
YeLFmJd8PJ49gJdRFubONrUTXOyXMKVLRrBlcEIIebGIM4yYp2hyBIZ0zaH1UGDh
kqYeOx5niXhd+tNmLMKXA4ZJ8Rmc/2Li6wtU/6Zuc3Chmo/qoZPv84FlvkN0zasg
ozIDmuT+9rhttnMpx5K0CwUbRWQkH+0EO/nBEdPfd4H1lLdfSE+jx2HRblymwXXg
hf1TM1+A7Mqh/6DYYCD4ZHpYgTqjMppbpF38wkA6d/tNKTQb5dE/9CIydNHeBzui
/Ku+T4e2e/J19ES96m4jrVaCNGm4S60SHPKWLyVcbhMrTgRFmk/QVbAU7bdv+VlP
B5K2Oo2guXVoEi+aZxU4vzyi7UNKtRXFj2qka0zmsRa+aWGq4TE1SOvo9D414VXs
FhHPUMQ+uL3kPJ7X7l7KLsBQpXBuTcBcypdMLjBs+vABF8cjPcRM/yDZhRgkAQZk
j6IexRrkXekZANI8ulZr
=ySBg
-----END PGP SIGNATURE-----

--=-cAV6ejsuBHu3mplXIwGy--
