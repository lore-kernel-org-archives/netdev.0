From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: linux-next: manual merge of the wireless-drivers-next tree with the net-next tree
Date: Fri, 02 Dec 2016 07:08:48 +0200
Message-ID: <87polark7z.fsf@kamboji.qca.qualcomm.com>
References: <20161202110313.2104919e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wireless <linux-wireless@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Sara Sharon <sara.sharon@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Rajkumar Manoharan <rmanohar@qti.qualcomm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53708 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcLBFIy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 00:08:54 -0500
In-Reply-To: <20161202110313.2104919e@canb.auug.org.au> (Stephen Rothwell's
        message of "Fri, 2 Dec 2016 11:03:13 +1100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi all,
>
> Today's linux-next merge of the wireless-drivers-next tree got a
> conflict in:
>
>   drivers/net/wireless/ath/ath10k/mac.c
>
> between commit:
>
>   f3fe4e93dd63 ("mac80211: add a HW flag for supporting HW TX fragmentation")
>
> from the net-next tree and commit:
>
>   ff32eeb86aa1 ("ath10k: advertize hardware packet loss mechanism")
>
> from the wireless-drivers-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

The fix looks good, thanks. I sent a pull request to Dave yesteday which
should fix this.

-- 
Kalle Valo
