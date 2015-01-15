From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH for 3.19 3/3] rtlwifi: rtl8192ee: Fix several bugs
Date: Thu, 15 Jan 2015 13:42:52 +0200
Message-ID: <87bnm0xoar.fsf@kamboji.qca.qualcomm.com>
References: <1421257036-5382-1-git-send-email-Larry.Finger@lwfinger.net>
	<1421257036-5382-4-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:54208 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbAOLnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 06:43:00 -0500
In-Reply-To: <1421257036-5382-4-git-send-email-Larry.Finger@lwfinger.net>
	(Larry Finger's message of "Wed, 14 Jan 2015 11:37:16 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> From: Troy Tan <troy_tan@realsil.com.cn>
>
> The following bugs are fixed in this driver:
> 1. Problems parsing C2H CMD
> 2. An ad-hoc connection can cause a TX freeze.
> 3. There are additional conditions that cause a TX freeze.
> 4. The previous code failed to handle situations where an RX
>    descriptor was unavailable.
>
> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Is this really so important that it should go to 3.19? A patch titled
"Fix several bugs" immediately makes me cautious and then I look at the
patch itself I see rewriting functions instead of simple bug fixes. From
a quick look this looks more -next material than 3.19.

-- 
Kalle Valo
