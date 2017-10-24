From: Yossi Kuperman <yossiku@mellanox.com>
Subject: RE: [PATCH] ipv4: esp4: use BUG_ON instead of if condition followed
 by BUG
Date: Tue, 24 Oct 2017 09:29:53 +0000
Message-ID: <AM4PR0501MB2274CFCF78488F3FBF0BB00FC4470@AM4PR0501MB2274.eurprd05.prod.outlook.com>
References: <20171023180608.GA25108@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "'Gustavo A. R. Silva'" <garsilva@embeddedor.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023180608.GA25108@embeddedor.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: [PATCH] ipv4: esp4: use BUG_ON instead of if condition followed =
by
> BUG
>=20
> Use BUG_ON instead of if condition followed by BUG in esp_remove_trailer.
>=20
> This issue was detected with the help of Coccinelle.
>=20
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  net/ipv4/esp4.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20

Please consider esp6 as well.
