From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath6kl: fix return value in ath6kl_wmi_set_pvb_cmd
Date: Wed, 28 Sep 2016 12:01:41 +0200
Message-ID: <30b5c8aa25144295b86244424860d80e@euamsexm01a.eu.qualcomm.com>
References: <20160918063024.2535-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        Chaehyun Lim <chaehyun.lim@gmail.com>
To: Chaehyun Lim <chaehyun.lim@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:44672 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751888AbcI1KBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 06:01:50 -0400
In-Reply-To: <20160918063024.2535-1-chaehyun.lim@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chaehyun Lim <chaehyun.lim@gmail.com> wrote:
> When building with W=1, we got one warning as belows:
> drivers/net/wireless/ath/ath6kl/wmi.c:3509:6: warning: variable ‘ret’
> set but not used [-Wunused-but-set-variable]
> 
> At the end of ath6kl_wmi_set_pvb_cmd, it is returned by 0 regardless of
> return value of ath6kl_wmi_cmd_send.
> This patch fixes return value from 0 to ret that has result of
> ath6kl_wmi_cmd_send execution.
> 
> Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>

Patch applied to ath-next branch of ath.git, thanks.

b93015057e31 ath6kl: fix return value in ath6kl_wmi_set_pvb_cmd

-- 
https://patchwork.kernel.org/patch/9337611/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
