From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 3/4] net: ethernet: cpsw: split out IRQ handler
Date: Fri, 2 Jan 2015 21:02:38 -0600
Message-ID: <20150103030238.GA19959@saruman>
References: <1420222228-31949-1-git-send-email-balbi@ti.com>
 <1420222228-31949-4-git-send-email-balbi@ti.com>
 <CAA93jw7qyZjdHGKXjiBhiYp4BWBFrUFM6FF-Lzc0i7eOnM6cNg@mail.gmail.com>
 <20150102185535.GB4920@saruman>
 <CAA93jw7=aFM3yQLO+vtN4uHW2gMnfNaY=BdbA+b0WYq-0+gSYQ@mail.gmail.com>
 <20150102190350.GC4920@saruman>
 <CAA93jw4BckMYOz_fUMVkW8m1YVO8uGjsb1srrhiF-meDoiD1WA@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Cc: Felipe Balbi <balbi@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux OMAP Mailing List <linux-omap@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:53772 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbbACDDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2015 22:03:09 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw4BckMYOz_fUMVkW8m1YVO8uGjsb1srrhiF-meDoiD1WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Jan 02, 2015 at 02:56:36PM -0800, Dave Taht wrote:
> On Fri, Jan 2, 2015 at 11:03 AM, Felipe Balbi <balbi@ti.com> wrote:
> > Hi,
> >
> > (please use reply-all to keep mailing lists in Cc, also avoid
> > top-posting)
>=20
> I am trying not to read netdev right now... and failing, obviously.

oops :-)

> > On Fri, Jan 02, 2015 at 10:58:29AM -0800, Dave Taht wrote:
> >> The beaglebone only has a 100mbit phy, so you aren't going to get more
> >> than that.
> >
> > very true :-) Still, with AM437x SK which is definitely GigE, I'm
> > getting 201Mbits/sec.
> >
> >> (so do a lot of IoT devices).
> >>
> >> So you have the two patches that went by on BQL and on NAPI for the be=
agle?
> >
> > no, got any pointers ?
>=20
> the relevant thread was "am335x: cpsw: phy ignores max-speed setting"
>=20
> and the initial very small BQL enablement patch was here:
>=20
> https://patchwork.ozlabs.org/patch/407640/

I'll test it out, sure.

> (it needed a saner treatment of a failure to dma something in
> cpsw_tx_packet_submit  - the patch as is has also been part of nelsons
> trees for the beaglebone for a while)
>=20
> But it was rightly pointed out later in the thread that this change
>=20
> +#define CPSW_POLL_WEIGHT 16
>=20
> made for the biggest part of the improvement, and someone else on the
> thread proposed handling that more dynamically for 100mbit phys with
> another patch (that I can't find at the moment)
>=20
> ... but the root cause of the excessive latency in this driver was the
> single tx/rx dma queue, which you are addressing  in your patch set.

I still think there's a lot of work pending for CPSW, the think slows to
a crawl and takes a lot of CPU for something that should be mostly
handled by DMA. I can very easily get 85% CPU usage with iperf.

> So if you glop on more of the above, mo better, perhaps you will win
> bigger.
>=20
> I will try to slice out some time to boot up a beagle on net-next next we=
ek.

my patches aren't applied yet, however.

cheers

--=20
balbi

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUp1vOAAoJEIaOsuA1yqREm1gP/0z4KoxkQp9/N3Y4IVLT44j3
c5voy1pNgWiJn/DCGG0TdCq4PM9J3uKaTnM8wInBH38vOKW0nFSzHlSYUf8SoEd0
k5EUhp53r259RDu1gTGNmxAV8R3aBBQga0luQX/U2wKRYeh1H0exlKxCWuaHSe3v
7p6WdwLsgx204pind2IEnWTG/DqOfP5UKnFCOIE2p5ZB4Vo2O8562us36p0SXFXX
esATQT51TQIp3JMPm7DcCBxQE6KfAF3vRNMdApSuMgctyC/gNjsbwuzfLT0z4FUd
sBT5YpB6kr2SyXdMxKnHmFPAdiBb7CxRNdo5DmdIO577o6AX/5Ym49tbWV5tdCzd
4ryMIoI7FZAxvt6lzc3QVHqlrZuD/zPsjJ8484P6O3k9Uhhv+8lOrnnUcFV1TEvr
CWwUV3b/ReCxX8EHKB5nw5Iej/Kfhi2L2h7EFmEgB+Q6TMBbCIVTSZQxmr8H21ZO
J+F7xOk6SgvR2Z1r8eNWJZP/06XxXP95LF17tPQb5uR8IxLpUdxpWuIXwAgE6qOn
ZQ7RgbevJE3/qVMqMpSIWtMmJUEcWQ1wnE7YW27WJr2/N8GEb7uPA8T9+83RPsZ/
IVD2HqNFdw0FjeTysi9hnpFc44Iq0eYuP4HHTd2AajCNNwnpZa/RQgidoeFbuiEk
5R0mCdgsvA3wgl5t3Qu4
=zIb8
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
