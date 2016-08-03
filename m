From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 1/1 v2] rtlwifi: remove superfluous condition
Date: Wed, 03 Aug 2016 09:01:54 +0300
Message-ID: <8737mm5r1p.fsf@kamboji.qca.qualcomm.com>
References: <4e6de16f-b42c-920a-60a2-fcc88e282dc0@lwfinger.net>
	<1470165981-6241-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48145 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbcHCG3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 02:29:34 -0400
In-Reply-To: <1470165981-6241-1-git-send-email-xypron.glpk@gmx.de> (Heinrich
	Schuchardt's message of "Tue, 2 Aug 2016 21:26:21 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Heinrich Schuchardt <xypron.glpk@gmx.de> writes:

> If sta == NULL, the changed line will not be reached.
> So no need to check that sta != NULL here.
>
> v2:
> 	fix typo
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

The change log goes under the "---" line so that git can automatically
strip it away while committing the patch. I can fix it this time but
please keep this in mind in the future.

-- 
Kalle Valo
