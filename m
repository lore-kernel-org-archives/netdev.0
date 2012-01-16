From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix unused variable warning in
 xt_hashlimit.c
Date: Mon, 16 Jan 2012 13:39:25 +0100
Message-ID: <20120116123925.GA13131@1984>
References: <20120111115217.b5db064c4bf233a4e1df42b8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120111115217.b5db064c4bf233a4e1df42b8@canb.auug.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2012 at 11:52:17AM +1100, Stephen Rothwell wrote:
> Fixes this warning when CONFIG_IP6_NF_IPTABLES is not enabled:
>=20
> net/netfilter/xt_hashlimit.c: In function =E2=80=98hashlimit_init_dst=
=E2=80=99:
> net/netfilter/xt_hashlimit.c:448:9: warning: unused variable =E2=80=98=
frag_off=E2=80=99 [-Wunused-variable]
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
