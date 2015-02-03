From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V2,for,3.19,3/7] rtlwifi: rtl8192ee: Fix adhoc fail
Date: Tue,  3 Feb 2015 13:15:16 +0000 (UTC)
Message-ID: <20150203131516.799471409D0@smtp.codeaurora.org>
References: <1421773286-1039-4-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:33999 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbbBCNPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 08:15:17 -0500
In-Reply-To: <1421773286-1039-4-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Troy Tan <troy_tan@realsil.com.cn>
> 
> When the buffer descriptor index exceeds 2, then a TX HANG condition
> will result.
> 
> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [V3.18]

Thanks, 4 patches applied to wireless-drivers-next.git:

b661a5da5776 rtlwifi: rtl8192ee: Fix adhoc fail
6e5f44361628 rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write point
92ff754240b8 rtlwifi: rtl8192ee: Fix parsing of received packet
21b39ddb5bb2 rtlwifi: rtl8192ee: Fix DMA stalls

3 patches skipped:

[V2,for,3.19,1/7] rtlwifi: Remove logging statement that is no longer needed
[V2,for,3.19,2/7] rtlwifi: rtl8192ee: Fix handling of new style descriptors
[V2,for,3.19,6/7] rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO

Kalle Valo
