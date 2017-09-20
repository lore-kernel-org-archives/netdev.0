From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rsi: fix a dereference on adapter before it has been null checked
Date: Wed, 20 Sep 2017 12:40:41 +0000 (UTC)
Message-ID: <20170920124041.DE3EA60134@smtp.codeaurora.org>
References: <20170908152452.3594-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amit.karwar@redpinesignals.com>,
        Prameela Rani Garnepudi <prameela.j04cs@gmail.com>,
        Karun Eagalapati <karun256@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48388 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbdITMkm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 08:40:42 -0400
In-Reply-To: <20170908152452.3594-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> The assignment of dev is dereferencing adapter before adapter has
> been null checked, potentially leading to a null pointer dereference.
> Fix this by simply moving the assignment of dev to a later point
> after the sanity null check of adapter.
> 
> Detected by CoverityScan CID#1398383 ("Dereference before null check")
> 
> Fixes: dad0d04fa7ba ("rsi: Add RS9113 wireless driver")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to wireless-drivers-next.git, thanks.

6508497cbdc7 rsi: fix a dereference on adapter before it has been null checked

-- 
https://patchwork.kernel.org/patch/9944509/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
