From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] rtlwifi: Improve handling of IPv6 packets
Date: Thu, 26 Feb 2015 14:56:36 +0200
Message-ID: <87zj80de63.fsf@kamboji.qca.qualcomm.com>
References: <1424791381-31863-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>, Alan Fisher <acf@unixcube.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56963 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbbBZM4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 07:56:42 -0500
In-Reply-To: <1424791381-31863-1-git-send-email-Larry.Finger@lwfinger.net>
	(Larry Finger's message of "Tue, 24 Feb 2015 09:23:01 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

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

Should this go to 4.0?

-- 
Kalle Valo
