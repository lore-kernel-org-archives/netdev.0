From: Valdis.Kletnieks@vt.edu
Subject: Re: next-20151207 - crash in IPv6 code
Date: Tue, 08 Dec 2015 16:54:17 -0500
Message-ID: <4883.1449611657@turing-police.cc.vt.edu>
References: <3884.1449551563@turing-police.cc.vt.edu>
 <20151208113409.GA31055@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1449611657_2588P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pablo@netfilter.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208113409.GA31055@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1449611657_2588P
Content-Type: text/plain; charset=us-ascii

On Tue, 08 Dec 2015 12:34:09 +0100, Florian Westphal said:
> Valdis Kletnieks <Valdis.Kletnieks@vt.edu> wrote:
>
> [ CC Pablo ]
>
> > Seen this in 2 boots out of two on next-20151207 when IPV6 networking
> > was available.  It was stable when no net was available. Also, next-20161127 is OK.
> > Haven't bisected it yet - this ring any bells?
>
> Thanks for the report, my fault -- its caused by
> 029f7f3b8701cc7aca8bdb which is only in Pablos nf-next tree.
>
> This should fix this bug (proper patch w. changelog coming
> after more testing):
>
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c

Pumped about 100M of IPv6 traffic through, and no problems.

Feel free to stick a Reported-by:/Tested-By: on this patch...

--==_Exmh_1449611657_2588P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVmdRiQdmEQWDXROgAQI8qQ//XpELgTr16DdvvwpqpZWhm1XqfecQwELF
AR+yOX/micGWoyftfPfMDcUPEY9Hd4s9Q/8NA0fbeYC6C5jZJxXBrCg1Vz0IfkoY
g73nN9Nh5UV9fLNpxHhNZFfO6Gt+vpb9jqDIwE/ExGzJxOY14SDpl+VqyG8uxhfO
5lkt+0fMpUJ/Cr8Zn9cGdYOK4+HtTaozMhBZtlnc4kxNWxplBqBvsBNDujrjJL87
gV1mVeDERnVH8yj7/wbssz62HyVslwltFDZ8yV2X7bXCQ+wYo+klj1Qkkcnt6cxr
K2K3vCO1TjYhLptw1+1oS5mn9BOdSoVMlb4PvvrxSIrF2+UMOVgSJz4rVhADZDq9
oLS1SWku+YCXCn3aNtSp22MaQAmTuKA/Wv02MN7ZPGc6AbO3AR63vknAR4oQfT52
pWD9twSepkDUwFHHgQ796sbYTnVDemUybpLwExgjUXyM8I8ke1PWPzvp/Nzi5Kb9
mDnwTYmeoV0+7NCYIH7WYlIQa5qDkeZ+65kYjyaVcydsCttTcSQQ0zSfVlQ63rTZ
6joMYFY4+HTPCHgWAJzXQALWjoclp+fx1JOt54+SLc4D87ucow1saI/6IA9bgZys
3nLEgcBEdioyTxwN15hvW+nLsACczqYzrr4cbrydwnliPxc7G0ok0NyeZAfDMuMR
11y5Eno0HRk=
=z2Vt
-----END PGP SIGNATURE-----

--==_Exmh_1449611657_2588P--
