From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: Replace semaphore async_sem with mutex
Date: Tue, 13 Jun 2017 07:05:52 +0000 (UTC)
Message-ID: <20170613070552.B281F601D9@smtp.codeaurora.org>
References: <1496916183-4097-1-git-send-email-binoy.jayan@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Binoy Jayan <binoy.jayan@linaro.org>, linux-kernel@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Rajendra <rnayak@codeaurora.org>,
        Mark Brown <broonie@kernel.org>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Binoy Jayan <binoy.jayan@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46462 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753024AbdFMHF6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 03:05:58 -0400
In-Reply-To: <1496916183-4097-1-git-send-email-binoy.jayan@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binoy Jayan <binoy.jayan@linaro.org> wrote:

> The semaphore 'async_sem' is used as a simple mutex, so
> it should be written as one. Semaphores are going away in the future.
> 
> Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

1abf9ae719f6 mwifiex: Replace semaphore async_sem with mutex

-- 
https://patchwork.kernel.org/patch/9774361/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
