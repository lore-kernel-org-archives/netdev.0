From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: asix: Staticise non-exported symbols
Date: Tue, 13 Aug 2013 14:14:19 -0700 (PDT)
Message-ID: <20130813.141419.1602310190735729196.davem@davemloft.net>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, broonie@linaro.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141Ab3HMVOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:14:23 -0400
In-Reply-To: <1376069482-16951-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Fri,  9 Aug 2013 18:31:21 +0100

> From: Mark Brown <broonie@linaro.org>
> 
> Make functions that are only referenced from ops structures static, they
> do not need to be in the global namespace and sparse complains about this.
> 
> Signed-off-by: Mark Brown <broonie@linaro.org>

Applied.
