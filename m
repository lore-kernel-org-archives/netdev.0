From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] rtlwifi: Remove double check for cnt_after_linked
Date: Wed, 11 May 2016 18:55:39 +0000 (UTC)
Message-ID: <20160511185539.51E2E6133D@smtp.codeaurora.org>
References: <20160505150822.GA4151@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wang yanqing <udknight@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35501 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbcEKSzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 14:55:40 -0400
In-Reply-To: <20160505150822.GA4151@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wang yanqing <udknight@gmail.com> wrote:
> rtl_lps_enter does two successive check for cnt_after_linked
> to make sure some time has elapsed after linked. The second
> check isn't necessary, because if cnt_after_linked is bigger
> than 5, it is bigger than 2 of course!
> 
> This patch remove the second check code.
> 
> Signed-off-by: Wang YanQing <udknight@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

976aff5fc94b rtlwifi: Remove double check for cnt_after_linked

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9025161/
