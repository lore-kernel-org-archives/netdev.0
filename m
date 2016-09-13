From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [V2] ath10k: fix memory leak on caldata on error exit path
Date: Tue, 13 Sep 2016 14:24:40 +0200
Message-ID: <c603113a967a45c18ddce5deff55b753@euamsexm01a.eu.qualcomm.com>
References: <20160903163819.13115-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ath10k@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160903163819.13115-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> caldata is not being free'd on the error exit path, causing
> a memory leak and data definitely should not be freed. Free
> caldata instead of data.
> 
> Thanks to Kalle Valo for spotting that data should not be
> free'd.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks, 1 patch applied to ath-next branch of ath.git:

5f4761dda2ba ath10k: fix memory leak on caldata on error exit path

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9312163/
