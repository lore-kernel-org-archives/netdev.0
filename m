From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Do not dereference NULL in chnl_recv_cb()
Date: Mon, 20 Aug 2012 02:48:08 -0700 (PDT)
Message-ID: <20120820.024808.184015666899890382.davem@davemloft.net>
References: <alpine.LNX.2.00.1208172230570.15699@swampdragon.chaosbits.net>
	<81C3A93C17462B4BBD7E272753C1057923B924D522@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jj@chaosbits.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <81C3A93C17462B4BBD7E272753C1057923B924D522@EXDCVYMBSTM005.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Date: Mon, 20 Aug 2012 08:33:35 +0200

>> In net/caif/chnl_net.c::chnl_recv_cb() we call skb_header_pointer()
>> which may return NULL, but we do not check for a NULL pointer before
>> dereferencing it.
>> This patch adds such a NULL check and properly free's allocated memo=
ry
>> and return an error (-EINVAL) on failure - much better than crashing=
=2E.
>>=20
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>=20
> Thank you for fixing this, the patch looks good to me.
> Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks.
