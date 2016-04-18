From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH v3] carl9170: Clarify kconfig text
Date: Mon, 18 Apr 2016 18:24:03 +0200
Message-ID: <1601274.2AA5eFGnzj@debian64>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com> <87shyiyl8a.fsf@purkki.adurom.net> <20160418190739.bea7c781e2bd35beb7a748f7@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lauri Kasanen <cand@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32899 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbcDRQYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 12:24:08 -0400
In-Reply-To: <20160418190739.bea7c781e2bd35beb7a748f7@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 18, 2016 07:07:39 PM Lauri Kasanen wrote:
> The previous text was confusing, leading readers to think this
> driver was a duplicate, and so didn't need to be enabled.
> 
> After the removal of the older staging driver, this is the only
> driver in mainline for these devices.
> 
> Signed-off-by: Lauri Kasanen <cand@gmx.com>
> ---
> v3: Remove all firmware mentions.
> 
>  drivers/net/wireless/ath/carl9170/Kconfig | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/carl9170/Kconfig b/drivers/net/wireless/ath/carl9170/Kconfig
> index 1a796e5..ca1ae09 100644
> --- a/drivers/net/wireless/ath/carl9170/Kconfig
> +++ b/drivers/net/wireless/ath/carl9170/Kconfig
> @@ -5,13 +5,7 @@ config CARL9170
>  	select FW_LOADER
>  	select CRC32
>  	help
> -	  This is another driver for the Atheros "otus" 802.11n USB devices.
> -
> -	  This driver provides more features than the original,
> -	  but it needs a special firmware (carl9170-1.fw) to do that.
> -
> -	  The firmware can be downloaded from our wiki here:
> -	  <http://wireless.kernel.org/en/users/Drivers/carl9170>
Please do keep the wiki link.
