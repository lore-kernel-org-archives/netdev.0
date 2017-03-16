From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath10k: remove redundant error check
Date: Thu, 16 Mar 2017 09:57:51 +0100
Message-ID: <f9f879b23b604117bf434e122146882e@euamsexm01a.eu.qualcomm.com>
References: <20170228111439.19546-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228111439.19546-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The check on ret for an error is redundant because it is already been
> checked for non-zero earlier on and ret is never non-zero at this point.
> Fix this by removing the redundant check and error message.
> 
> Detected by CoverityScan, CID#1357170 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to ath-next branch of ath.git, thanks.

51f60b8b6979 ath10k: remove redundant error check

-- 
https://patchwork.kernel.org/patch/9595221/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
