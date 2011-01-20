From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 13:30:57 +0800
Message-ID: <AANLkTi=NU=ANUDGGdiCL+AP696nF1kXwPHOPZPrCti2u@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295284788.21277.65.camel@Joe-Laptop> <AANLkTi=nJxwR89CF3i0+L6+yM4Bg_PN8PQByTAHP2nPM@mail.gmail.com>
 <1295455290.1952.22.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, dilinger@queued.net
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295455290.1952.22.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Joe,

On Thu, Jan 20, 2011 at 12:41 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2011-01-19 at 17:40 +0800, Po-Yu Chuang wrote:
>> Well, TBH, I don't like this style because if I changed the
>> function name, the indentation might need to be adjusted.
>
> No worries. =C2=A0That could happen using either style.
>
> There's no required style so you can use what you are
> most comfortable doing. =C2=A0It's not a big deal at all.
>
>> Even worse, I got an infeasible case :-(
>>
>> static struct ftmac100_rxdes *ftmac100_rx_locate_first_segment(
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0struct ftmac100 *priv)
>>
>> I know my function names are quite long, but I like them to be descr=
iptive.
>> Do you really insist on it?
>
> Here's a common alternative style for this case:
>
> static struct ftmac100_rxdes *
> ftmac100_rx_locate_first_segment(struct ftmac100 *priv)

OK, I see.

One more question: how to deal with this? Add a local variable for the
2nd argument?

	ftmac100_set_receive_ring_base(priv,
				       priv->descs_dma_addr + offsetof(struct ftmac100_descs, rxdes=
));

best regards,
Po-Yu Chuang
