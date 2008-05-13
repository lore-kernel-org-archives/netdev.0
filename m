From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] net/s2io: set_rxd_buffer_pointer returns -ENOMEM, notENOMEM
Date: Mon, 12 May 2008 20:56:57 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770389468A@nekter>
References: <20080511200421.GK19058@joi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>
To: "Marcin Slusarz" <marcin.slusarz@gmail.com>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:55313 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755626AbYEMA5A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 20:57:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080511200421.GK19058@joi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good catch! 

Jeff,
Please accept patch.

Thanks,
Ram

> -----Original Message-----
> From: Marcin Slusarz [mailto:marcin.slusarz@gmail.com]
> Sent: Sunday, May 11, 2008 1:04 PM
> To: LKML
> Cc: Ramkrishna Vepa; Rastapur Santosh; Sivakumar Subramani; Sreenivasa
> Honnur; netdev@vger.kernel.org
> Subject: [PATCH] net/s2io: set_rxd_buffer_pointer returns -ENOMEM,
> notENOMEM
> 
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
> Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
> Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Cc: netdev@vger.kernel.org
> ---
> compile tested only
> ---
>  drivers/net/s2io.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -6951,7 +6951,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic
*sp)
>  						       &skb,(u64
*)&temp0_64,
>  						       (u64 *)&temp1_64,
>  						       (u64 *)&temp2_64,
> -							size) == ENOMEM)
{
> +							size) ==
-ENOMEM) {
>  					return 0;
>  				}
> 
> --
