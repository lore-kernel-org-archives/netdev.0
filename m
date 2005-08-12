From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 17:37:30 +0200
Message-ID: <20050812153730.GR18580@rama.de.gnumonks.org>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
	<p73u0hv2xkv.fsf@verdi.suse.de> <42FC8EBC.1070505@trash.net>
	<20050812120319.GK8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QFliEIXSSz7hGqqc"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20050812120319.GK8974@wotan.suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--QFliEIXSSz7hGqqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 12, 2005 at 02:03:20PM +0200, Andi Kleen wrote:
> > Unfortunately one of the iptables structures which is needed to get the
> > ruleset in the kernel (ipt_replace) is differently sized when compiled
> > for 32/64 bit. IIRC it doesn't work at all currently.
>=20
> Yes that's the old bug and cannot be fixed without breaking compatibility=
=2E=20
>=20
> But we hope that ctnetlink will not repeat that mistake. That is why I'm =
suggesting
> to use aligned_u64 in all new interfaces

I'll soon push a patch for all nfnetlink_{conntrack,queue,log} stuff for
net-2.6.14.  Don't worry about that.

But getting back to the original connbytes issue.  Is it worth fixing
it, if the core iptables doesn't even work (the "old bug")?

I don't think that we're ever going to fix that bug in the old
{get,set}sockopt interface, but rather introduce a netlink interface
when pkt_tables matures.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--QFliEIXSSz7hGqqc
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/MI5XaXGVTD0i/8RAoZhAKCc7he6yu+V4jRGA99kVCYF8mbciQCgpRlY
MBXLSRexGEYkch/at3xoycw=
=drCZ
-----END PGP SIGNATURE-----

--QFliEIXSSz7hGqqc--
