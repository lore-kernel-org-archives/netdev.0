From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Thu, 11 Apr 2013 12:56:28 +0200
Message-ID: <20130411105628.GA4717@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
	<1365442863-32394-2-git-send-email-antonio@open-mesh.com>
	<CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
	<20130409075606.GB3771@open-mesh.com>
	<51641049.3030100@mojatatu.com>
	<20130409135143.GA5177@open-mesh.com>
	<5164387D.8080700@mojatatu.com>
	<20130410165434.GB5177@open-mesh.com>
	<20130410134609.46bcaeae@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130410134609.46bcaeae@nehalam.linuxnetplumber.net>
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

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 10, 2013 at 01:46:09PM -0700, Stephen Hemminger wrote:
> On Wed, 10 Apr 2013 18:54:34 +0200
> Antonio Quartulli <antonio@open-mesh.com> wrote:
>=20
> > Hi Jamal, all,
> >=20
> > On Tue, Apr 09, 2013 at 08:49:17 -0700, Jamal Hadi Salim wrote:
> > > On 13-04-09 09:51 AM, Antonio Quartulli wrote:
> > >=20
> > > >
> > > > Does this work at the bridge level? A packet entering a port and go=
ing out from
> > > > another one can be affected by tc/mark?
> > >=20
> > > Yes of course. And on any construct that looks like a netdev (tunnels=
 etc).
> > >=20
> >=20
> > Thanks for your hints. After having struggled a bit I found out how to =
do it
> > using ebtables and the mark target :)
> >=20
> > Thanks a Lot!
> >=20
> Come back again, though. The ebtables method offers more flexibility whic=
h can
> be a good or bad thing...

I just realised that :)

By installing ebtables (meaning modules + userspace tool) my iperf test res=
ult
drops from 81Mbps to 66Mbps: former without, latter with ebtables module en=
abled.
I did this test between two devices connected with Fast Ethernet.

I thought that most of the code is in netfilter, so shared with iptables, h=
ence
I expected a reasonable overhead why this is much worse.

Does anybody have a clue about this? I should probably start a new thread o=
n the
netfilter mailing list.

However this problem makes ebtables unusable at all.

Suggestions are welcome :)

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRZpbcAAoJEADl0hg6qKeOGTAP+wWW91XVRqcnSy1X6Iy/pkFl
KnR0llga9VwTOKqhAHYz6YDr+cZfL2ajzcxT/Jo1ap+vR5YNPbvQ9i4zOTEdoFAF
4PF40MPYj1592MI/XlCaF99Zpy3uv8TGxTw9r11oJO2PB7mpOX3+DkJN0l8s2Wqj
bT0YQ+ZmFTpmzXjOnWtbVkkNQvsIGAMQmnW+dwL1rRIV7lPHojbVIlCrIRFlWhd/
S2a1zxYGAO2k4QrsQIZV0dP759IDCmQD+WHydlNLPTp85C+f1019W/NR6q0ZRT0g
WMkHdLBHrJmaShumM7wqL1ruoBEtBvu11qBfHva2yT7shkjOE4Lu8Am2UZHAimwg
XIAD91CA5i/Y7PftOY3+7rIxULc5NZioFFcMi6ND3EN+2Et1keYKWhEV6b2UYf2A
cgIfcHR7FWl308NpjZvLwlvYBLKtV4StboVFc2YN7QuzbluqHf9/OvZ1eOIdEdEa
XLRW6P4fSUd80sHQfkKLSNcI37xZvQoDCH4BCk06CSxCEt2GfpvcLc7z3qmgl7Dh
sys9TkoeGAYbuwKaBHJB3IkpOsz54fcVRzIlfML3+dmPQ6+GLC/BUUQvCXElTnze
zpQhTdEM4yaCB2HvOw8FwFcA6m+pl32V83ckwuxADDPtkoEsdbVfDP9MVtryBb6t
xfB/esGBAZ9BoMymvG2s
=tmPf
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--
