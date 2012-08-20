From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH] caif: Do not dereference NULL in chnl_recv_cb()
Date: Mon, 20 Aug 2012 08:33:35 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C1057923B924D522@EXDCVYMBSTM005.EQ1STM.local>
References: <alpine.LNX.2.00.1208172230570.15699@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel MARTENSSON <daniel.martensson@stericsson.com>
To: Jesper Juhl <jj@chaosbits.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1208172230570.15699@swampdragon.chaosbits.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In net/caif/chnl_net.c::chnl_recv_cb() we call skb_header_pointer()
> which may return NULL, but we do not check for a NULL pointer before
> dereferencing it.
> This patch adds such a NULL check and properly free's allocated memor=
y
> and return an error (-EINVAL) on failure - much better than crashing.=
=2E
>=20
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Thank you for fixing this, the patch looks good to me.
Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
