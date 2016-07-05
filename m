From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH 00/11] pull request for net-next:
	batman-adv 2016-07-04
Date: Tue, 05 Jul 2016 11:02:05 +0200
Message-ID: <2972702.D1HUdGKSgq@prime>
References: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
 <20160704.233725.776967939409818077.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart7092014.vjJ4HJfF6a";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160704.233725.776967939409818077.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart7092014.vjJ4HJfF6a
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi David,

On Monday 04 July 2016 23:37:25 David Miller wrote:
> From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
> Date: Mon,  4 Jul 2016 15:02:48 +0200
> 
> > this is our second and final feature pull request for batman-adv in this
> > round.
> > 
> > Please pull or let me know of any problem!
> 
> Pulled, thanks.
> 
> I have no idea why you guys were using debugfs for anything that
> actually matters like configuration. :-/  debugfs should only be
> used for "debugging", such that if debugfs were not present the
> full functionality of the facility would still be present.

as Sven pointed out, debugfs was not used for configuration (except for very 
deep tune parameters which are really for debugging anyway). We use sysfs 
(formerly) and now rtnl for configuration.

However, debugfs has quite some tables showing the current state of the mesh 
(read only) which are obviously interesting for many users as well. Therefore 
we want to change to a netlink based interface in the long run, similar to 
what the wireless stack and iw are doing. This will also enable new features 
like proper namespace support, which we are going to integrate soon.

Cheers,
     Simon
--nextPart7092014.vjJ4HJfF6a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXe3eNAAoJEKEr45hCkp6hzusP/0d+UXtR3yeeJhcZIEOH5PwU
4w+elWkCzzFGZ18xj8RAzkJ4LxfZi+OiPlr/6dZp+8ix6GZjqNKR435enGanXU0J
MNOobBUk8DsYhUix/rmoYqxAu+N91OdCVFQH4m+TQYBY4F6nQ840eTrTue/kGT4l
DpXJlIvzASKL2EMrx4SC1hpTDTUJIo5NWpajKa/M8v5sd37ofTOyxhWy0sEIc5fb
IW1YVeZRu7aG2QZS+nbGwJtr3duPxmYSDEo2OPSCSRJzYKr7xeau9VRCJ6yMj9IQ
KXANN9KrXZr1A3gzO7jx27sKAUZgyy39FP8IPjV9293dqaxdVyZu4L7vsy+8+13i
wTGSAzOrHD3Z+un273v+SOoWPV2eBKTQbep2F1Qm3okj5h7cvsJFwMlDxG7iE5Dd
6CDJ7zIYNBLAeCGY2oLevpZvMtCFppc0NP8X9zQfDUzXM66eGIHRoGcfSlxp8ssl
zTK4lxN5TVvBrFcJW/06t0H1/B1FGC8BMeNx1WFw34XFiFvqSQMq8P9grdtNdBho
84eQ+0OG3Jf5zhu/mXt1+PeJgh2h37Jo7HLbSZm3tMzTYxSupNRyE4ijgB1sjjsn
Z7AGGhB94wA7XTIjK8Cp30fMjPUvG+WWHOND0+lzQzd18CwFHJJ4VKH1Yh3XScNr
UTWXUs9keT6D5INZzKns
=ktub
-----END PGP SIGNATURE-----

--nextPart7092014.vjJ4HJfF6a--
