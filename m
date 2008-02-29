From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6.26 2008-02-29
Date: Fri, 29 Feb 2008 13:55:29 -0800 (PST)
Message-ID: <20080229.135529.193701021.davem@davemloft.net>
References: <20080229212218.GG3234@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080229212218.GG3234-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 29 Feb 2008 16:22:18 -0500

> Here is a ton of wireless patches intended for 2.6.26 -- too much to go
> into details.
> 
> Let me know if there are problems!

Pulled and pushed back out to net-2.6.26, thanks.

Please fix the following build warnings:

drivers/net/wireless/ath5k/debug.c: In function 'read_file_tsf':
drivers/net/wireless/ath5k/debug.c:203: warning: format '%016llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
drivers/net/wireless/ath5k/debug.c:203: warning: format '%016llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
drivers/net/wireless/ath5k/debug.c: In function 'read_file_beacon':
drivers/net/wireless/ath5k/debug.c:274: warning: format '%016llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
drivers/net/wireless/ath5k/debug.c:274: warning: format '%016llx' expects type 'long long unsigned int', but argument 4 has type 'u64'

drivers/net/wireless/iwlwifi/iwl-4965.c: In function 'iwl4965_tx_status_reply_compressed_ba':
drivers/net/wireless/iwlwifi/iwl-4965.c:3907: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
drivers/net/wireless/iwlwifi/iwl-4965.c: In function 'iwl4965_rx_reply_compressed_ba':
drivers/net/wireless/iwlwifi/iwl-4965.c:4039: warning: format '%llx' expects type 'long long unsigned int', but argument 6 has type '__le64'
drivers/net/wireless/iwlwifi/iwl-4965.c:4046: warning: format '%llx' expects type 'long long unsigned int', but argument 5 has type 'u64'
drivers/net/wireless/iwlwifi/iwl4965-base.c: In function 'iwl4965_tx_status_reply_tx':
drivers/net/wireless/iwlwifi/iwl4965-base.c:3661: warning: format '%llx' expects type 'long long unsigned int', but argument 6 has type 'u64'
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
