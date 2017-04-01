From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/faraday: Explicitly include linux/of.h and
 linux/property.h
Date: Sat, 01 Apr 2017 12:14:38 -0700 (PDT)
Message-ID: <20170401.121438.906383309287383205.davem@davemloft.net>
References: <20170330160012.14824-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joel@jms.id.au, gwshan@linux.vnet.ibm.com, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdDATOl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 15:14:41 -0400
In-Reply-To: <20170330160012.14824-1-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Thu, 30 Mar 2017 17:00:12 +0100

> This driver uses interfaces from linux/of.h and linux/property.h but
> relies on implict inclusion of those headers which means that changes in
> other headers could break the build, as happened in -next for arm today.
> Add a explicit includes.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Applied, thank you.
