From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 3/3] iwlagn: Add missing comma between constant string
 array
Date: Mon, 11 Jul 2011 14:35:51 -0400
Message-ID: <20110711183550.GC2650@tuxdriver.com>
References: <cover.1310187270.git.joe@perches.com>
 <2c8a6e15b0f320e4b4b761ae6434862fc3c15924.1310187270.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2c8a6e15b0f320e4b4b761ae6434862fc3c15924.1310187270.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How is this array indexed?  Aren't you changing the index of the 
later strings?

On Fri, Jul 08, 2011 at 11:20:25PM -0700, Joe Perches wrote:
> Multiple quoted strings are concatenated without comma separators.
> 
> Make the array const while there.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/iwlwifi/iwl-agn.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
> index 7e6c463..de1a0c1 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-agn.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
> @@ -1563,7 +1563,7 @@ static void iwl_ucode_callback(const struct firmware *ucode_raw, void *context)
>  	release_firmware(ucode_raw);
>  }
>  
> -static const char *desc_lookup_text[] = {
> +static const char * const desc_lookup_text[] = {
>  	"OK",
>  	"FAIL",
>  	"BAD_PARAM",
> @@ -1587,7 +1587,7 @@ static const char *desc_lookup_text[] = {
>  	"NMI_INTERRUPT_DATA_ACTION_PT",
>  	"NMI_TRM_HW_ER",
>  	"NMI_INTERRUPT_TRM",
> -	"NMI_INTERRUPT_BREAK_POINT"
> +	"NMI_INTERRUPT_BREAK_POINT",
>  	"DEBUG_0",
>  	"DEBUG_1",
>  	"DEBUG_2",
> -- 
> 1.7.6.131.g99019
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
