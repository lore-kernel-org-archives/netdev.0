From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/3] iwlegacy: Add missing comma between constant string
 array
Date: Mon, 11 Jul 2011 14:35:42 -0400
Message-ID: <20110711183542.GB2650@tuxdriver.com>
References: <cover.1310187270.git.joe@perches.com>
 <36f8b5d1a32b8702941ebeda7a406188af132e9e.1310187270.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <36f8b5d1a32b8702941ebeda7a406188af132e9e.1310187270.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How is this array indexed?  Aren't you changing the index of the
later strings?

On Fri, Jul 08, 2011 at 11:20:24PM -0700, Joe Perches wrote:
> Multiple quoted strings are concatenated without comma separators.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wireless/iwlegacy/iwl4965-base.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
> index 46242d2..1433466 100644
> --- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
> +++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
> @@ -1484,7 +1484,7 @@ static const char * const desc_lookup_text[] = {
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
