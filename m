From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/15] net: bcm63xx_enet: Convert to use
 devm_ioremap_resource
Date: Wed, 12 Jun 2013 02:23:25 -0700 (PDT)
Message-ID: <20130612.022325.1006874954155178574.davem@davemloft.net>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
	<1370864113-17895-7-git-send-email-tushar.behera@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org
To: tushar.behera@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab3FLJX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 05:23:27 -0400
In-Reply-To: <1370864113-17895-7-git-send-email-tushar.behera@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Behera <tushar.behera@linaro.org>
Date: Mon, 10 Jun 2013 17:05:04 +0530

> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
> introduced devm_ioremap_resource() and deprecated the use of
> devm_request_and_ioremap().
> 
> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>

In net-next, the driver is already using devm_ioremap_resource().
