From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [2.6 patch] make IWLWIFI a tristate
Date: Tue, 06 May 2008 09:26:18 +0800
Message-ID: <1210037178.2827.152.camel@debian.sh.intel.com>
References: <87zlrgl09s.fsf@sparse.dyndns.org>
	 <1209435597.2624.35.camel@debian.sh.intel.com>
	 <20080505182516.GM17139@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jason Riedy <jason@acm.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55873 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762AbYEFB1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 21:27:42 -0400
In-Reply-To: <20080505182516.GM17139@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-05 at 21:25 +0300, Adrian Bunk wrote:
> 
> IWLWIFI should be a tristate so that if IWLCORE and/or IWL3945 are m
> and none of them is y kbuild doesn't create an empty 
> drivers/net/wireless/built-in.o
> 
> This patch also removes the pointless "default n".
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> f9737a109a127754ae7cc35e94d44fb426e0dea1 diff --git
> a/drivers/net/wireless/iwlwifi/Kconfig
> b/drivers/net/wireless/iwlwifi/Kconfig
> index d5b7a76..62fb89d 100644
> --- a/drivers/net/wireless/iwlwifi/Kconfig
> +++ b/drivers/net/wireless/iwlwifi/Kconfig
> @@ -1,6 +1,5 @@
>  config IWLWIFI
> -       bool
> -       default n
> +       tristate
>  
>  config IWLCORE
>         tristate "Intel Wireless Wifi Core"

Great. Thank you Adrian!

-yi

