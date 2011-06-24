From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/11] ixgbe: update perfect filter framework to
 support retaining filters
Date: Thu, 23 Jun 2011 23:40:44 -0700
Message-ID: <1308897644.11000.12.camel@Joe-Laptop>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308895397-23133-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3198 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583Ab1FXGkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:40:45 -0400
In-Reply-To: <1308895397-23133-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 23:03 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>

Just trivia

> diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
[]
> @@ -1484,6 +1427,101 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
>  	return 0;
>  }
>  
> +#define IXGBE_COMPUTE_BKT_HASH_ITERATION(_n) \
> +do { \
> +	u32 n = (_n); \
> +	if (IXGBE_ATR_BUCKET_HASH_KEY & (0x01 << n)) \
> +		bucket_hash ^= lo_hash_dword >> n; \
> +	if (IXGBE_ATR_BUCKET_HASH_KEY & (0x01 << (n + 16))) \
> +		bucket_hash ^= hi_hash_dword >> n; \
> +} while (0);

Don't need ; after while (0)


