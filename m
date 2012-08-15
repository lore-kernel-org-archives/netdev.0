From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] XFRM: remove redundant parameter "int dir" in
 struct xfrm_mgr.acquire
Date: Wed, 15 Aug 2012 15:14:03 -0700 (PDT)
Message-ID: <20120815.151403.2191772611303249590.davem@davemloft.net>
References: <1344996827-20620-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab2HOWOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 18:14:04 -0400
In-Reply-To: <1344996827-20620-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Wed, 15 Aug 2012 10:13:47 +0800

> Sematically speaking, xfrm_mgr.acquire is called when kernel intends to ask
> user space IKE daemon to negotiate SAs with peers. IOW the direction will
> *always* be XFRM_POLICY_OUT, so remove int dir for clarity.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
> Changelog for V2:
> 	- Remove "int dir" in build_acquire parameter suggested by Steffen Klassert.

Applied, thanks.

Please use lowercase "xfrm: " for subsystem indications in your subject
lines, I fixed it up this time.

Thanks again.
