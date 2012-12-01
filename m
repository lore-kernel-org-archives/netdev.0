From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] net: fix possible deadlocks in
	rtnl_trylock/unlock
Date: Sat, 01 Dec 2012 20:57:51 +0100
Message-ID: <8364190.7CxpSxJp4n@sven-laptop.home.narfation.org>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <10264267.HX5FJDguj3@sven-laptop.home.narfation.org>
 <1354391074.20109.527.camel@edumazet-glaptop>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2077854.yX76nCY1ap";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1354391074.20109.527.camel@edumazet-glaptop>
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


--nextPart2077854.yX76nCY1ap
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"

On Saturday 01 December 2012 11:44:34 Eric Dumazet wrote:
[...]
> > > I have no idea of why you believe there is a problem here.
> > > 
> > > Could you explain how net_todo_list could be not empty ?
> > > 
> > > As long as no device is unregistered between
> > > rtnl_trylock()/rtnl_unlock(), there is no possible deadlock.
> > 
> > I am not sure what "here" means for your. At least batman-adv tries to
> > unregister a device -> problem [1]. I will not make any judgements about
> > the other uses in the kernel/other parts patched by Simon.
> 
> I was reacting to the change in net/bridge/br_sysfs_br.c

Yes, in this context it makes more sense.

> rtnl_trylock() could set a boolean flag to explicitly WARN_ON()
> in case we try to unregister a device.

Sounds interesting.

Kind regards,
	Sven
--nextPart2077854.yX76nCY1ap
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQumE/AAoJEF2HCgfBJntGfY8P/03bnqGzBKy4G1frmXzPt9UU
3mTHjOk4YHYePqOGDaeKYuIqyx51N90ZyrW4s34cD4cCfjeNO1mqNpa3hXPuJaHa
z7hzg8ZVy0E9PvxEccuszPf8knCM98PnczrOLEDYzqdAULt7ONmc9bAWQ1jJWpiK
v5/0fe2ufU0UXXURnuolAR+BufKdCXwzFENC6QunAC45bGxP95UmgvbsxtOnWbl9
hkPJ4EebGnLbDWF/+37le3eBLI4+gnQmDWLfHpUaaRcQxv3fOGGDmBTcYWCB4A7x
1cxPINAVTHmdMAvrCs+O5zO04CzXlZOvfu9J+z78K+GvC1EULxUKJa6px0lsl0Cf
AB4WXtP1989WIbf6n9p4kG3LX2AWmlLZL6c1KxTP21A/zSfZARZRDGojILLwhvo4
ftpv5M+0cse1WQhzrCKcWohlFmiYJGk8g6PWcTPjRY+GauK1nVc+z9DDkLTqnGuQ
4uTTgLwSvW1myz8Ikks72W7g+yizd7z1oEeIk6Kpk8D339DJJSW4zvPS1CfzK0xS
y/AX9nugWk0KkWCEXPNgP+EpCrRc4BIv+hFRX6sLb02DC0z+yvcSisNF6Ukm7Ff9
SdN9Q+1DuSmhpeMHwhx0ZksM9J0uv93lIvEdf+H8Vnpxn2s+G3fFQqp3FSBMFz1p
FGzgKQUPXukdR8TSWXxB
=VO3b
-----END PGP SIGNATURE-----

--nextPart2077854.yX76nCY1ap--
