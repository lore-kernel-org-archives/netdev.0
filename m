From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: ie_list is an array, so no need to check if NULL
Date: Thu,  7 Apr 2016 16:39:40 +0000 (UTC)
Message-ID: <20160407163941.00A54611CD@smtp.codeaurora.org>
References: <1459180413-13288-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51987 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753683AbcDGQjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 12:39:42 -0400
In-Reply-To: <1459180413-13288-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Colin Ian King <colin.king@canonical.com>
> 
> ap_ie->ie_list is an array of struct mwifiex_ie and can never
> be null, so the null check on this array is redundant and can
> be removed.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
