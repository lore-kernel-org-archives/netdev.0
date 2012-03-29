From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 5/5] r8169: support RTL8411
Date: Thu, 29 Mar 2012 11:12:29 +0200
Message-ID: <20120329091229.GA22410@electric-eye.fr.zoreil.com>
References: <1332923214-5071-1-git-send-email-hayeswang@realtek.com> <1332923214-5071-5-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1332923214-5071-5-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Support the new chip RTL8411.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |  142 +++++++++++++++++++++++++++++++++-
>  1 files changed, 139 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index cde5cea..d00f4e9 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -250,7 +252,10 @@ static const struct {
>  							JUMBO_9K, false),
>  	[RTL_GIGA_MAC_VER_37] =
>  		_R("RTL8402",		RTL_TD_1, FIRMWARE_8402_1,
> -							JUMBO_1K, true)
> +							JUMBO_1K, true),
> +	[RTL_GIGA_MAC_VER_38] =
> +		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_1,
> +							JUMBO_9K, false)

rtl_init_jumbo_ops probably needs to be updated as well.

Nit: please keep a colon in 'JUMBO_9K, false),'.
                                             ^
There was one after the (not so) last record before patch 03/05 and I would
prefer it to stay because new devices are regularly added. The '-' line is
only noise.

Thanks.

-- 
Ueimor
