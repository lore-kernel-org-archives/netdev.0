From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [net-next] qtnfmac: fix uninitialized return code in ret
Date: Wed, 28 Jun 2017 17:50:30 +0000 (UTC)
Message-ID: <20170628175030.F05F460AFB@smtp.codeaurora.org>
References: <20170621132530.11937-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        "David S . Miller" <davem@davemloft.net>,
        Bindu Therthala <btherthala@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55978 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdF1Rub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 13:50:31 -0400
In-Reply-To: <20170621132530.11937-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> The return value ret is unitialized and garbage is being returned
> for the three different error conditions when setting up the PCIe
> BARs. Fix this by initializing ret to  -ENOMEM to indicate that
> the BARs failed to be setup correctly.
> 
> Detected by CoverityScan, CID#1437563 ("Unitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Reviewed-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>

Patch applied to wireless-drivers-next.git, thanks.

3e3d8aa61107 qtnfmac: fix uninitialized return code in ret

-- 
https://patchwork.kernel.org/patch/9801833/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
