From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: add NV congestion control
Date: Mon, 06 Jun 2016 23:42:20 -0700 (PDT)
Message-ID: <20160606.234220.424326125644791412.davem@davemloft.net>
References: <1464986278-2096156-3-git-send-email-brakmo@fb.com>
	<20160606.160108.1481703166637051807.davem@davemloft.net>
	<D37B5339.19584%brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com,
	stephen@networkplumber.org, kennetkl@ifi.uio.no
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537AbcFGGma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 02:42:30 -0400
In-Reply-To: <D37B5339.19584%brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 7 Jun 2016 01:04:06 +0000

> The reason why this may be necessary, is that under some conditions
> NV flows competing with more aggressive flows will perform
> poorly. People may be more willing to test NV if there is a quick
> and simple way to revert if necessary (without having to restart the
> flows).

This is a property that may apply to any congestion control algorithm
whatsoever, not just NV.
