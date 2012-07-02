From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [RFC] [TCP 0/3] Receive from socket into bio without copying
Date: Mon, 2 Jul 2012 16:39:28 +0300
Message-ID: <CAMAG_eeDXghHXYxBXK08cweimvdFVr_vCk2f47_OHGZgux7zuw@mail.gmail.com>
References: <1340981632.25226.2.camel@gurkel.linbit> <1340982523.21162.1.camel@edumazet-glaptop>
 <1341229532.29646.39.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Gruenbacher <agruen@linbit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341229532.29646.39.camel@gurkel.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 2, 2012 at 2:45 PM, Andreas Gruenbacher <agruen@linbit.com>=
 wrote:

>
> We want to go directly to the block layer instead. =C2=A0This require=
s that
> the network hardware receives the data into sector aligned buffers.
> Hence the proposed MSG_NEW_PACKET flag.
Andreas,
 I didn't read your patches, but what are you looking for can't be
achieved using "normal" NICs, for that you need to use RDMA protocol
with a hardware that supports RDMA.

saeed
