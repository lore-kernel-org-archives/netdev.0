From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] ixen-netback: fix trivial printf format build warning
Date: Wed, 26 Mar 2014 10:09:07 +0000
Message-ID: <1395828547.22808.28.camel@kazak.uk.xensource.com>
References: <1395806210-23528-1-git-send-email-sj38.park@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <trivial@kernel.org>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: SeongJae Park <sj38.park@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395806210-23528-1-git-send-email-sj38.park@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-26 at 12:56 +0900, SeongJae Park wrote:
> Fix following trivial build warning:
>=20
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_dea=
lloc_action=E2=80=99:
> drivers/net/xen-netback/netback.c:1585:8: warning:
> format =E2=80=98%x=E2=80=99 expects argument of type
>  =E2=80=98unsigned int=E2=80=99, but argument 3 has type =E2=80=98lon=
g int=E2=80=99 [-Wformat=3D]
>         gop - vif->tx_unmap_ops, ret);
>         ^
>=20
> Signed-off-by: SeongJae Park <sj38.park@gmail.com>

Thanks but davem indicated overnight that he has already pushed a
suitable fix to net-next.

Ian.
