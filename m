From: "Belgazal, Netanel" <netanel@amazon.com>
Subject: Re: [PATCH net-next 09/13] net: ena: adding missing cast in
 ena_com_mem_addr_set()
Date: Mon, 19 Jun 2017 12:45:08 +0000
Message-ID: <1497876308540.71961@amazon.com>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
 <1497785298-13468-10-git-send-email-netanel@amazon.com>,<20170619050009.GK17846@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Woodhouse, David" <dwmw@amazon.co.uk>,
        "Machulsky, Zorik" <zorik@amazon.com>,
        "Matushevsky, Alexander" <matua@amazon.com>,
        "BSHARA, Said" <saeedb@amazon.com>,
        "Wilson, Matt" <msw@amazon.com>,
        "Liguori, Anthony" <aliguori@amazon.com>,
        "Bshara, Nafea" <nafea@amazon.com>,
        "Schmeilin, Evgeny" <evgenys@amazon.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:54771 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753696AbdFSMrn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 08:47:43 -0400
In-Reply-To: <20170619050009.GK17846@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack,=0A=
=0A=
Will use the proposed functions.=0A=
________________________________________=0A=
From: Leon Romanovsky <leon@kernel.org>=0A=
Sent: Monday, June 19, 2017 8:00 AM=0A=
To: Belgazal, Netanel=0A=
Cc: davem@davemloft.net; netdev@vger.kernel.org; Woodhouse, David; Machulsk=
y, Zorik; Matushevsky, Alexander; BSHARA, Said; Wilson, Matt; Liguori, Anth=
ony; Bshara, Nafea; Schmeilin, Evgeny=0A=
Subject: Re: [PATCH net-next 09/13] net: ena: adding missing cast in ena_co=
m_mem_addr_set()=0A=
=0A=
On Sun, Jun 18, 2017 at 02:28:14PM +0300, netanel@amazon.com wrote:=0A=
> From: Netanel Belgazal <netanel@amazon.com>=0A=
>=0A=
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>=0A=
> ---=0A=
>  drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-=0A=
>  1 file changed, 1 insertion(+), 1 deletion(-)=0A=
>=0A=
> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethe=
rnet/amazon/ena/ena_com.c=0A=
> index f6e1d30523a6..8efb85e25a42 100644=0A=
> --- a/drivers/net/ethernet/amazon/ena/ena_com.c=0A=
> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c=0A=
> @@ -100,7 +100,7 @@ static inline int ena_com_mem_addr_set(struct ena_com=
_dev *ena_dev,=0A=
>       }=0A=
>=0A=
>       ena_addr->mem_addr_low =3D (u32)addr;=0A=
> -     ena_addr->mem_addr_high =3D (u64)addr >> 32;=0A=
> +     ena_addr->mem_addr_high =3D (u16)((u64)addr >> 32);=0A=
=0A=
We have macro for getting upper 32 bits - upper_32_bits(addr), the same=0A=
goes for lower 32 bits.=0A=
=0A=
>=0A=
>       return 0;=0A=
>  }=0A=
> --=0A=
> 2.7.4=0A=
>=0A=
