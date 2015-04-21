From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: stmmac: use msleep instead of udelay for gpio
 reset
Date: Tue, 21 Apr 2015 17:35:40 -0400 (EDT)
Message-ID: <20150421.173540.1253961571051792975.davem@davemloft.net>
References: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, festevam@gmail.com, netdev@vger.kernel.org
To: michael@amarulasolutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096AbbDUVfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 17:35:42 -0400
In-Reply-To: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Trimarchi <michael@amarulasolutions.com>
Date: Tue, 21 Apr 2015 13:16:13 +0200

> -			udelay(data->delays[0]);
 ...
> +			msleep(max(1U, data->delays[0] / 1000));

That looks very ugly with that max() expression in there.

Please find some clean way to get rid of it if you want to
make this conversion.

Thanks.
