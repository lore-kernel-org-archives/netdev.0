From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] Revert "bnx2x: allow nvram test to run
 when device is down"
Date: Tue, 30 Apr 2013 19:01:15 -0400 (EDT)
Message-ID: <20130430.190115.792841420974833189.davem@davemloft.net>
References: <1367353482-24529-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933643Ab3D3XBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 19:01:20 -0400
In-Reply-To: <1367353482-24529-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 30 Apr 2013 23:24:42 +0300

> This reverts commit d2d2d87dfd1a25ee270994c5b9e3eb4690428d32
> ("bnx2x: allow nvram test to run when device is down").
> 
> Since it makes access to the device in D3 state possible.
> More work is required to make sure device is not set to D3
> during ifdown. Until this is done the nvram-test should simply
> exit if device is down like it did before.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
