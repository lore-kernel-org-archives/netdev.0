From: Krzysztof Kozlowski <krzk@kernel.org>
Subject: Re: [PATCH 5/8] linux: drop __bitwise__ everywhere
Date: Thu, 15 Dec 2016 19:28:39 +0200
Message-ID: <20161215172839.GA6520@kozik-lap>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
 <1481778865-27667-6-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	Krzysztof Kozlowski <krzk@kernel.org>,
	Javier Martinez Canillas <javier@osg.samsung.com>,
	Russell King <linux@armlinux.org.uk>,
	Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com, Shaohua Li <shli@kernel.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.com>, Lee Duncan <lduncan@suse.com>,
	Chris Leech <cleech@redhat.com>,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Jason Wang <jasowang@redhat.com>,
	Alexander Aring <aar@pengutronix.de
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1481778865-27667-6-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 07:15:20AM +0200, Michael S. Tsirkin wrote:
> __bitwise__ used to mean "yes, please enable sparse checks
> unconditionally", but now that we dropped __CHECK_ENDIAN__
> __bitwise is exactly the same.
> There aren't many users, replace it by __bitwise everywhere.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  arch/arm/plat-samsung/include/plat/gpio-cfg.h    | 2 +-
>  drivers/md/dm-cache-block-types.h                | 6 +++---
>  drivers/net/ethernet/sun/sunhme.h                | 2 +-
>  drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h | 4 ++--
>  include/linux/mmzone.h                           | 2 +-
>  include/linux/serial_core.h                      | 4 ++--
>  include/linux/types.h                            | 4 ++--
>  include/scsi/iscsi_proto.h                       | 2 +-
>  include/target/target_core_base.h                | 2 +-
>  include/uapi/linux/virtio_types.h                | 6 +++---
>  net/ieee802154/6lowpan/6lowpan_i.h               | 2 +-
>  net/mac80211/ieee80211_i.h                       | 4 ++--
>  12 files changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/arch/arm/plat-samsung/include/plat/gpio-cfg.h b/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> index 21391fa..e55d1f5 100644
> --- a/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> +++ b/arch/arm/plat-samsung/include/plat/gpio-cfg.h
> @@ -26,7 +26,7 @@
>  
>  #include <linux/types.h>
>  
> -typedef unsigned int __bitwise__ samsung_gpio_pull_t;
> +typedef unsigned int __bitwise samsung_gpio_pull_t;
>  
>  /* forward declaration if gpio-core.h hasn't been included */
>  struct samsung_gpio_chip;

For plat-samsung:
Acked-by: Krzysztof Kozlowski <krzk@kernel.org>

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
