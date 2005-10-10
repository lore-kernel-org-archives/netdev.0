From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [ANNOUNCE] iproute2 version (050929)
Date: Mon, 10 Oct 2005 07:40:02 -0700
Message-ID: <20051010074002.5cd642da@localhost.localdomain>
References: <20050930150406.2e2221fd@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510012332580.14848@bizon.gios.gov.pl>
	<20051005113458.46f0892d@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0510101232310.1343@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.62.0510101232310.1343@bizon.gios.gov.pl>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Mon, 10 Oct 2005 12:34:51 +0200 (CEST)
Krzysztof Oledzki <olel@ans.pl> wrote:

>=20
>=20
> On Wed, 5 Oct 2005, Stephen Hemminger wrote:
>=20
> > On Sat, 1 Oct 2005 23:34:25 +0200 (CEST)
> > Krzysztof Oledzki <olel@ans.pl> wrote:
> >
> >>
> >>
> >> On Fri, 30 Sep 2005, Stephen Hemminger wrote:
> >>
> >>> There is an new minor update to iproute2 utilities available:
> >>> 	http://developer.osdl.org/dev/iproute2/download/iproute2-050929.ta=
r.gz
> >>
> >>
> >> It hangs on "ip rule flush". Tested on 2.6.13.2.
> >>
> >>
> >> Best regards,
> >>
> >>
> >>  			Krzysztof Ol=C4=99dzki
> >
> > Fixed by this patch (in next release)
>=20
> Not sure... Just checked iproute2-ss051007 and it still hangs on "ip ru=
le=20
> flush" with ~100% cpu load.
>=20

Are you running as root? If not it will loop forever.
