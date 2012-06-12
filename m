From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] iwlwifi: re-order module_init order to prevent NULL ptr
 deref
Date: Tue, 12 Jun 2012 21:17:28 +0200
Message-ID: <1339528648.4531.15.camel@jlt3.sipsolutions.net>
References: <1339528412-4163-1-git-send-email-levinsasha928@gmail.com>
	 (sfid-20120612_211247_722972_E0F3BAE7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, linville@tuxdriver.com,
	ilw@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339528412-4163-1-git-send-email-levinsasha928@gmail.com> (sfid-20120612_211247_722972_E0F3BAE7)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-06-12 at 21:13 +0200, Sasha Levin wrote:
> We need to make sure iwl_drv_init is called before iwl_init, since otherwise
> iwl_init will NULL ptr deref when trying to add a new mode.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  drivers/net/wireless/iwlwifi/Makefile |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlwifi/Makefile b/drivers/net/wireless/iwlwifi/Makefile
> index 98c8f64..16e39a4 100644
> --- a/drivers/net/wireless/iwlwifi/Makefile
> +++ b/drivers/net/wireless/iwlwifi/Makefile
> @@ -1,5 +1,3 @@
> -obj-$(CONFIG_IWLDVM)	+= dvm/
> -

Thanks! I already have a patch like this in my tree, will send a pull
request soon:

http://git.kernel.org/?p=linux/kernel/git/iwlwifi/iwlwifi-next.git;a=commit;h=4b75b1e49568dd6a30a1dddc47408cc6fde55608

johannes
