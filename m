From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: make NET_DSA manually selectable from the
 config
Date: Fri, 20 Mar 2015 21:39:53 -0400 (EDT)
Message-ID: <20150320.213953.1521386254972813549.davem@davemloft.net>
References: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux@roeck-us.net, jiri@resnulli.us,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbbCUBjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 21:39:55 -0400
In-Reply-To: <1426901463-31913-1-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Olivari <mathieu@codeaurora.org>
Date: Fri, 20 Mar 2015 18:31:03 -0700

> Change bd76a116707bd2381da36cf7c3183df11293f1d6 made all DSA drivers
> depend on NET_DSA rather than selecting them. However, as the only way
> to select this option was to actually select a driver, it made DSA
> impossible to enable at all.
> 
> This patch adds an explicit entry which the user will have to enable
> prior selecting a driver.
> 
> Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>

Applied.
