From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] net: qlcnic: avoid superfluous assignement
Date: Mon, 1 Aug 2016 10:57:20 +0800
Message-ID: <CAD=hENdsPG5u77N0vEnapSPmkJrLsPcXBUJ82s6msVX72sAi1g@mail.gmail.com>
References: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dept-GELinuxNICDev@qlogic.com, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36506 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbcHAC6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 22:58:13 -0400
In-Reply-To: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry.
An inline function will be inserted into the calling function. Why
"Assigning NULL to parmeter dcb has no effect outside of the
inlined function." ?

On Sun, Jul 31, 2016 at 6:07 PM, Heinrich Schuchardt <xypron.glpk@gmx.de> wrote:
> Assigning NULL to parmeter dcb has no effect outside of the
> inlined function.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
> index 9777e57..f4aa633 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
> @@ -45,7 +45,6 @@ struct qlcnic_dcb {
>  static inline void qlcnic_clear_dcb_ops(struct qlcnic_dcb *dcb)
>  {
>         kfree(dcb);
> -       dcb = NULL;
>  }
>
>  static inline int qlcnic_dcb_get_hw_capability(struct qlcnic_dcb *dcb)
> --
> 2.8.1
>
