From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] mwifiex: advertise low priority scan feature
Date: Wed,  6 Apr 2016 18:43:37 +0000 (UTC)
Message-ID: <20160406184337.61C95615D6@smtp.codeaurora.org>
References: <1458619796-7694-1-git-send-email-wnhuang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, akarwar@marvell.com,
	djkurtz@chromium.org, Wei-Ning Huang <wnhuang@chromium.org>,
	nishants@marvell.com, netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33870 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbcDFSni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 14:43:38 -0400
In-Reply-To: <1458619796-7694-1-git-send-email-wnhuang@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Amitkumar Karwar <akarwar@marvell.com>
> 
> Low priority scan handling code which delays or aborts scan
> operation based on Tx traffic is removed recently. The reason
> is firmware already takes care of it in our new feature scan
> channel gap. Hence we should advertise low priority scan
> support to cfg80211.
> 
> This patch fixes a problem in which OBSS scan request from
> wpa_supplicant was being rejected by cfg80211.
> 
> Signed-off-by: Amitkumar Karwar <akarwar@marvell.com>
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
> Tested-by: Wei-Ning Huang <wnhuang@chromium.org>
> Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
