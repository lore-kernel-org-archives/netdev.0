From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath5k: fix memory leak on buf on failed eeprom read
Date: Fri, 19 May 2017 09:52:27 +0200
Message-ID: <31364cad256e4b409906f66efd7dd6d0@euamsexm01a.eu.qualcomm.com>
References: <20170503142600.32609-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>,
        Nick Kossifidis <mickflemm@gmail.com>,
        "Luis R . Rodriguez" <mcgrof@do-not-panic.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        <linux-wireless@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>, <netdev@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:2313 "EHLO
        wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750755AbdESHwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 03:52:36 -0400
In-Reply-To: <20170503142600.32609-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The AR5K_EEPROM_READ macro returns with -EIO if a read error
> occurs causing a memory leak on the allocated buffer buf. Fix
> this by explicitly calling ath5k_hw_nvram_read and exiting on
> the via the freebuf label that performs the necessary free'ing
> of buf when a read error occurs.
> 
> Detected by CoverityScan, CID#1248782 ("Resource Leak")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to ath-next branch of ath.git, thanks.

8fed6823e06e ath5k: fix memory leak on buf on failed eeprom read

-- 
https://patchwork.kernel.org/patch/9709935/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
