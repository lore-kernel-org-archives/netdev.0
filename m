From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: Improve handling of IPv6 packets
Date: Tue,  3 Mar 2015 15:07:39 +0000 (UTC)
Message-ID: <20150303150739.BBC7C14162A@smtp.codeaurora.org>
References: <1424791381-31863-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Alan Fisher <acf@unixcube.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49800 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927AbbCCPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 10:07:40 -0500
In-Reply-To: <1424791381-31863-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Routine rtl_is_special_data() is supposed to identify packets that need to
> use a low bit rate so that the probability of successful transmission is
> high. The current version has a bug that causes all IPv6 packets to be
> labelled as special, with a corresponding low rate of transmission. A
> complete fix will be quite intrusive, but until that is available, all
> IPv6 packets are identified as regular.
> 
> This patch also removes a magic number.
> 
> Reported-and-tested-by: Alan Fisher <acf@unixcube.org>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org> [3.18+]
> Cc: Alan Fisher <acf@unixcube.org>

Thanks, applied to wireless-drivers.git.

Kalle Valo
