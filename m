From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/3] wireless: iwlwifi: wrap macro into braces
Date: Wed, 04 Oct 2017 09:14:24 -0700
Message-ID: <1507133664.4434.7.camel@perches.com>
References: <20171004155700.18048-1-christoph@boehmwalder.at>
         <20171004155700.18048-4-christoph@boehmwalder.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph =?ISO-8859-1?Q?B=F6hmwalder?=
        <christoph@boehmwalder.at>, johannes.berg@intel.com,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004155700.18048-4-christoph@boehmwalder.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-04 at 17:57 +0200, Christoph Böhmwalder wrote:
> Macros should always be wrapped in braces, so fix this instance.
> 
> Signed-off-by: Christoph Böhmwalder <christoph@boehmwalder.at>
> ---
>  drivers/net/wireless/intel/iwlwifi/iwl-io.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-io.c b/drivers/net/wireless/intel/iwlwifi/iwl-io.c
> index efb1998dcabd..0211963b3e71 100644
> --- a/drivers/net/wireless/intel/iwlwifi/iwl-io.c
> +++ b/drivers/net/wireless/intel/iwlwifi/iwl-io.c
> @@ -252,7 +252,7 @@ IWL_EXPORT_SYMBOL(iwl_force_nmi);
>  
>  static const char *get_rfh_string(int cmd)
>  {
> -#define IWL_CMD(x) case x: return #x
> +#define IWL_CMD(x) { case x: return #x; }

I think this unnecessary.  Maybe:
http://lists.infradead.org/pipermail/ath10k/2017-February/009335.html

>  #define IWL_CMD_MQ(arg, reg, q) { if (arg == reg(q)) return #reg; }

But this should use do { ... } while (0)
