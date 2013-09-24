From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH 12/19] wireless: Change variable type to bool
Date: Tue, 24 Sep 2013 13:54:49 +0300
Message-ID: <87wqm6sd52.fsf@purkki.adurom.net>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
	<1379802471-30252-12-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from purkki.adurom.net ([80.68.90.206]:54699 "EHLO purkki.adurom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab3IXKyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 06:54:53 -0400
In-Reply-To: <1379802471-30252-12-git-send-email-peter.senna@gmail.com> (Peter
	Senna Tschudin's message of "Sun, 22 Sep 2013 00:27:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Senna Tschudin <peter.senna@gmail.com> writes:

> The variable continual is only assigned the values true and false.
> Change its type to bool.
>
> The simplified semantic patch that find this problem is as
> follows (http://coccinelle.lip6.fr/):
>
> @exists@
> type T;
> identifier b;
> @@
> - T
> + bool
>   b = ...;
>   ... when any
>   b = \(true\|false\)
>
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> ---
>  drivers/net/wireless/rtlwifi/efuse.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Please prefix the patch title with "rtlwifi:". We use "wireless:" for
changes to net/wireless.

-- 
Kalle Valo
