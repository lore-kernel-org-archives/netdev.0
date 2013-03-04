From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nfnetlink: silence warning if
 CONFIG_PROVE_RCU isn't set
Date: Mon, 4 Mar 2013 16:59:46 +0100
Message-ID: <20130304155946.GA25980@localhost>
References: <1362401141.16460.24.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1362401141.16460.24.camel@x61.thuisdomein>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 04, 2013 at 01:45:41PM +0100, Paul Bolle wrote:
> Since commit c14b78e7decd0d1d5add6a4604feb8609fe920a9 ("netfilter:
> nfnetlink: add mutex per subsystem") building nefnetlink.o without
> CONFIG_PROVE_RCU set, triggers this GCC warning:
>     net/netfilter/nfnetlink.c:65:22: warning: =E2=80=98nfnl_get_lock=E2=
=80=99 defined but not used [-Wunused-function]
>=20
> The cause of that warning is, in short, that rcu_lockdep_assert()
> compiles away if CONFIG_PROVE_RCU is not set. Silence this warning by
> open coding nfnl_get_lock() in the sole place it was called, which
> allows to remove that function.

Applied, thanks Paul.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
