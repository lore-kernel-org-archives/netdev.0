From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.22 4/4]S2IO: Implementing review comments from old patches
Date: Sat, 14 Jul 2007 00:26:33 +0200
Message-ID: <20070713222633.GE18669@electric-eye.fr.zoreil.com>
References: <Pine.GSO.4.10.10707120620210.16507-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Veena Parat <Veena.Parat@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33775 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbXGMW3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 18:29:07 -0400
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10707120620210.16507-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veena Parat <Veena.Parat@neterion.com> :
> Implementation of review comments
>  - Incorporated Jeff Garzik's comments on coding standards
>  - Incorporated Andreas Schwab's comments on redundant condition check
> 
> Signed-off-by: Veena Parat <veena.parat@neterion.com>
[...]
> diff -Nurp 2.0.23.1P3/drivers/net/s2io.h 2.0.23.1P4/drivers/net/s2io.h
> --- 2.0.23.1P3/drivers/net/s2io.h	2007-07-03 23:58:40.000000000 -0700
> +++ 2.0.23.1P4/drivers/net/s2io.h	2007-07-04 02:54:29.000000000 -0700
> @@ -464,7 +464,7 @@ struct TxD {
>  #define TXD_LIST_OWN_XENA       BIT(7)
>  #define TXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
>  #define TXD_T_CODE_OK(val)      (|(val & TXD_T_CODE))
> -#define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)<<12)
> +#define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)>> 48)
>  #define TXD_GATHER_CODE         (BIT(22) | BIT(23))
>  #define TXD_GATHER_CODE_FIRST   BIT(22)
>  #define TXD_GATHER_CODE_LAST    BIT(23)
> @@ -503,6 +503,7 @@ struct RxD_t {
>  	u64 Control_1;
>  #define RXD_OWN_XENA            BIT(7)
>  #define RXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
> +#define GET_RXD_T_CODE(val)     ((val & RXD_T_CODE) >> 48)
>  #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
>  #define RXD_FRAME_PROTO_IPV4    BIT(27)
>  #define RXD_FRAME_PROTO_IPV6    BIT(28)

I must be more dense than usual tonight but it does not seem related to
the description of the patch.

-- 
Ueimor
