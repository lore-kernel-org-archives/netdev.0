From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Wed, 10 Apr 2013 13:46:09 -0700
Message-ID: <20130410134609.46bcaeae@nehalam.linuxnetplumber.net>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
	<1365442863-32394-2-git-send-email-antonio@open-mesh.com>
	<CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
	<20130409075606.GB3771@open-mesh.com>
	<51641049.3030100@mojatatu.com>
	<20130409135143.GA5177@open-mesh.com>
	<5164387D.8080700@mojatatu.com>
	<20130410165434.GB5177@open-mesh.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
	boundary="Sig_/wI388Gb..N0bVq12t1pknj=";
	protocol="application/pgp-signature"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130410165434.GB5177@open-mesh.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--Sig_/wI388Gb..N0bVq12t1pknj=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 10 Apr 2013 18:54:34 +0200
Antonio Quartulli <antonio@open-mesh.com> wrote:

> Hi Jamal, all,
>=20
> On Tue, Apr 09, 2013 at 08:49:17 -0700, Jamal Hadi Salim wrote:
> > On 13-04-09 09:51 AM, Antonio Quartulli wrote:
> >=20
> > >
> > > Does this work at the bridge level? A packet entering a port and goin=
g out from
> > > another one can be affected by tc/mark?
> >=20
> > Yes of course. And on any construct that looks like a netdev (tunnels e=
tc).
> >=20
>=20
> Thanks for your hints. After having struggled a bit I found out how to do=
 it
> using ebtables and the mark target :)
>=20
> Thanks a Lot!
>=20
> These patches seem to be useless now
>=20
> Cheers,
>=20

Come back again, though. The ebtables method offers more flexibility which =
can
be a good or bad thing...

--Sig_/wI388Gb..N0bVq12t1pknj=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRZc+RAAoJEICnf2CVzeR+K3QQAJlVpGWGsCOeoxlG8NNvdriw
iyMTBoCyEuyBFot1SdLF6QrXsKNhiuv3FdGJTXAKTEUUkDaRUDTeMFRTFFWqH2N/
3d98/cGM2oE8yx4ANDJuTqYpaoKux6NAZzU4nQku4ELiJGzAuniqVWOUwkP8+MJ+
ljVOzvyBWCE+WKC2ccsYrQUSni/65hdO2avrABU9tYgIoRADlKbDZYUEj2psowZb
q4Z48V3VMPHkJOl1Pg1zES8m58jTBzLA6XyfYDV9nf5gQJVSDAYPVXaY3VwNRgC7
2E/d2eAh9pJtmHuU0O0XiuwG8jLy6zv0ld8nyB0iqt3DG2loSbwzG+vcHVnR3zAT
9ZhQ+hBNspZNSe0ZVb9IPTYkoiCRC9AJnnhReTO7HkUYsiFj/phZOHZaNSzQohfw
x0k6Sr3E7t5+YK5h28BDTFYnhtrQa+AvfNnNGb9is2jflj9CpxBEkChpkT0leqYs
83VIl4zwJUh4BpTn1mNKC5g5kE3YsvqHhxUpblbLh7/2sOuFSSwYMteUcFfRAluh
gVgeEoUdmpc4EJfxk4wk3fU56BNnRG1sT5e9S/6hJbtQMrmDEx9qv09tlNPUpdIN
OGP+3oTyFCIVlqe2YJ6xD0g0mVbadyVEAlUMs2kU+YKmCF6Q1fgG4ugZtmFGDfKK
JXo2fkQEZ08yfSvAlVGA
=7xYr
-----END PGP SIGNATURE-----

--Sig_/wI388Gb..N0bVq12t1pknj=--
