From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCHv4 net] i40e: Implement ndo_gso_check()
Date: Thu, 15 Jan 2015 01:03:16 -0800
Message-ID: <1421312596.2632.3.camel@jtkirshe-mobl>
References: <1417804872-58635-1-git-send-email-joestringer@nicira.com>
	 <1417806738.2404.42.camel@jtkirshe-mobl>
	 <CAEP_g=8mS=P2U_vU2ZMEBUkU8jWo5t2P0h9kxF_jbzJhExAZ9g@mail.gmail.com>
	 <CAEP_g=8iRKx9HPf0KRt6m=6pqAuMeT8_9GM8L+uFe+bMoxk33Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bdIHet2La4Nb+nPyLShL"
Cc: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"linux.nics" <linux.nics@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=8iRKx9HPf0KRt6m=6pqAuMeT8_9GM8L+uFe+bMoxk33Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bdIHet2La4Nb+nPyLShL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-14 at 18:24 -0800, Jesse Gross wrote:
> On Fri, Dec 26, 2014 at 3:58 PM, Jesse Gross <jesse@nicira.com> wrote:
> > On Fri, Dec 5, 2014 at 2:12 PM, Jeff Kirsher
> > <jeffrey.t.kirsher@intel.com> wrote:
> >> On Fri, 2014-12-05 at 10:41 -0800, Joe Stringer wrote:
> >>> ndo_gso_check() was recently introduced to allow NICs to report the
> >>> offloading support that they have on a per-skb basis. Add an
> >>> implementation for this driver which checks for IPIP, GRE, UDP
> >>> tunnels.
> >>>
> >>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> >>> ---
> >>> v4: Simplify the check to just do tunnel header length.
> >>>     Fix #define style issue.
> >>> v3: Drop IPIP and GRE (no driver support even though hw supports it).
> >>>     Check for UDP outer protocol for UDP tunnels.
> >>> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
> >>>     Add MAX_INNER_LENGTH (as 80).
> >>> ---
> >>>  drivers/net/ethernet/intel/i40e/i40e_main.c |   12 ++++++++++++
> >>>  1 file changed, 12 insertions(+)
> >>
> >> Thanks Joe, I will update the patch in my queue with your latest
> >> version.
> >
> > Jeff, as a heads-up, this patch and the corresponding one for fm10k
> > will no longer apply now that the ndo has changed. This was changed by
> > 5f35227e ("net: Generalize ndo_gso_check to ndo_features_check"). The
> > update needed is trivial and is just due to the change in the function
> > signature but I'm not sure where you are in the testing process with
> > this.
>=20
> Jeff - just wanted to check if you had seen this.

Yeah, I have the updated patch in my queue.  I was hoping to get this
patch pushed later this week.  It did not make the series of i40e
patches I am preparing to send out in the next couple of hours, but
should be in the next series or the series following the next.  Holidays
put a damper on things unfortunately.

--=-bdIHet2La4Nb+nPyLShL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUt4JUAAoJEOVv75VaS+3OqmQQAJ26GSsuG4RAMPzrsvKvoklt
voz1xMTPhp0CCJmgwzpr9J7Zw7+7OwmNMmzZRmE4J27cqNgbAGoTwybMcnK4oC6f
LxuUMUsqS26Sb/XM6QUC39sinKxgpe8ZpuHI05IUug3p+TwlWhYalwcjApP/YLyR
5rrC9eBPHU1LcuroPuM2ERRfMUdEwtrGI9gt3SETHnqFNaaEgwlO4TJbzznHQ+2R
jamOjgZ8AGm1wuhFr/xIRfxISvargtP3DlDKTvb12psbOW7EWPWTsY/8KG6Y3SrE
p20UTR6BU0Jq5O69lU5U7MvPQLFi8PkkPrPTYK8S0mnB5rICFEA00KJ9xdlQL8Z2
gCrMCyK6c9yUfH9/HUNOcoD5kFwIIB9Ousc78LKUBOsoUQVdjvb9fqo5CNiAwI9s
kZ9FSb3G3dKhxLiE9Y42Q8RueUNT7TaRTnBPsbcFfpK8DIP9VRAcPiCaP0kNdu8c
LpBCuZEubMdWz0uL60edTaiZblDzoZT+2mCGad66tRhuyCm24L8XVeM096xs7aqG
WtPiFmdr86K6pMagVV4XFa6Cr6RupaWdFkj/G8ar7MuWnKNDMGKYsgnp+KsGx9Lo
3fNHbEOOuan91LWCqEGTrsD+h8mt29puW3JY2oiMeZdKFZrhaAG0gRMF2uSORl3T
AQMxFUjdGIxpUXpUOy1l
=Vb8j
-----END PGP SIGNATURE-----

--=-bdIHet2La4Nb+nPyLShL--
