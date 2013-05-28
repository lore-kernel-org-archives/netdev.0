From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 3/4] net: wireless: remove unnecessary
 platform_set_drvdata()
Date: Mon, 27 May 2013 22:37:00 -0700 (PDT)
Message-ID: <20130527.223700.1424548383388665672.davem@davemloft.net>
References: <000301ce5b61$368e3dd0$a3aab970$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	jirislaby@gmail.com, mickflemm@gmail.com, mcgrof@qca.qualcomm.com,
	jouni@qca.qualcomm.com, vthiagar@qca.qualcomm.com,
	senthilb@qca.qualcomm.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932788Ab3E1FhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:37:10 -0400
In-Reply-To: <000301ce5b61$368e3dd0$a3aab970$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 28 May 2013 14:07:11 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
