From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH 5/8] linux: drop __bitwise__ everywhere
Date: Mon, 19 Dec 2016 11:09:28 +0200
Message-ID: <1482138568.26174.8.camel@coelho.fi>
References: <1481778865-27667-1-git-send-email-mst@redhat.com>
	 <1481778865-27667-6-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kukjin Kim <kgene@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>,
 Javier Martinez Canillas <javier@osg.samsung.com>, Russell King
 <linux@armlinux.org.uk>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer
 <snitzer@redhat.com>, dm-devel@redhat.com,  Shaohua Li <shli@kernel.org>,
 Johannes Berg <johannes.berg@intel.com>, Emmanuel Grumbach
 <emmanuel.grumbach@intel.com>, Intel Linux Wireless <linuxwifi@intel.com>,
 Kalle Valo <kvalo@codeaurora.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Lee Duncan
 <lduncan@suse.com>, Chris Leech <cleech@redhat.com>,  "James E.J.
 Bottomley" <jejb@linux.vnet.ibm.com>, "Martin K. Petersen"
 <martin.petersen@oracle.com>,  "Nicholas A. Bellinger"
 <nab@linux-iscsi.org>, Jason Wang <jasowang@redhat.com>, Alexander Aring
 <aar@pengutronix.de>, Stefan Schmidt <stefan@osg.samsung.com>, "David S.
 Miller" <davem@d
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1481778865-27667-6-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-15 at 07:15 +0200, Michael S. Tsirkin wrote:
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

For drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h:

Acked-by: Luca Coelho <luciano.coelho@intel.com>

--
Luca.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
