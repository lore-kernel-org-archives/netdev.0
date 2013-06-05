From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] net: ipv6: Fix incompatible pointer type warning
Date: Wed, 5 Jun 2013 12:23:54 +0200
Message-ID: <20130605102354.GA24766@debian>
References: <1370262068-16658-1-git-send-email-emilgoode@gmail.com>
 <20130604.171456.2052649822776872955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, lorenzo@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130604.171456.2052649822776872955.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

I'm sorry, the patch applies to the linux-next tree.
In the future I will be very careful about sending patches that fix
problems related to the merging of different trees.

Best regards,

Emil Goode

On Tue, Jun 04, 2013 at 05:14:56PM -0700, David Miller wrote:
> From: Emil Goode <emilgoode@gmail.com>
> Date: Mon,  3 Jun 2013 14:21:08 +0200
>=20
> > This fixes the sparse warning below about assignment from
> > incompatible pointer type.
> >=20
> > In the following commit the third argument in function ipv6_chk_add=
r
> > was changed to const and struct nf_ipv6_ops was introduced with
> > the third argument of .chk_addr beeing const.
> >=20
> > 2a7851bffb008ff4882eee673da74718997b4265
> > ("netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6")
> >=20
> > The below commit introduced the warning as the third argument of
> > dummy_ipv6_chk_addr and .ipv6_chk_addr in struct pingv6_ops is
> > missing a const.
> >=20
> > 6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
> > ("net: ipv6: Add IPv6 support to the ping socket.")
> >=20
> > Sparse output:
> >=20
> > net/ipv6/ping.c: In function =E2=80=98pingv6_init=E2=80=99:
> > net/ipv6/ping.c:87:27: warning:
> > 	assignment from incompatible pointer type [enabled by default]
> >=20
> > Signed-off-by: Emil Goode <emilgoode@gmail.com>
>=20
> This only happens when you combine net with net-next, therefore your
> patch isn't actually relevent to any real GIT tree.
>=20
> Please make this very clear in the future.
