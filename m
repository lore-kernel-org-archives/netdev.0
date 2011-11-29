From: David Miller <davem@davemloft.net>
Subject: Re: [RFCv2 9/9] caif-xshm: Add CAIF driver for Shared memory for
 M7400
Date: Tue, 29 Nov 2011 14:47:25 -0500 (EST)
Message-ID: <20111129.144725.183069721.davem@davemloft.net>
References: <1322595550-6473-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322595550-6473-10-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linus.walleij@linaro.org,
	sjurbren@gmail.com, pebolle@tiscali.nl, netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322595550-6473-10-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue, 29 Nov 2011 20:39:10 +0100

> This patch introduces a caif shared memory link layer driver
> for ST-Ericsson's Thor M7400 LTE modem.
>=20
> M7400 uses a ring-buffer in shared memory for transporting data from =
the modem.
> Each ring-buffer element contains an array of caif frames. caif_xshm =
calls
> napi_schedule() when receiving notification about incoming data.
> The napi-poll function copies data from the ring-buffer to SKBs until
> ring-buffer is empty, or quota is exceeded.
>=20
> If transmit ring-buffer is full, it also uses napi for scheduling tra=
nsmission
> of queued transmit buffer.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> cc: netdev@vger.kernel.org

I'm happy for this to go into the tree where the necessary xshm infrast=
ructure
goes first:

Acked-by: David S. Miller <davem@davemloft.net>
