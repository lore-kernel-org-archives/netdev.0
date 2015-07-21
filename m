From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers: net: cpsw: remove tx event processing in
 rx napi poll
Date: Tue, 21 Jul 2015 10:43:24 -0700 (PDT)
Message-ID: <20150721.104324.1090468772682144332.davem@davemloft.net>
References: <1437474642-32175-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGURnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:43:25 -0400
In-Reply-To: <1437474642-32175-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 21 Jul 2015 16:00:42 +0530

> With commit c03abd84634d ("net: ethernet: cpsw: don't requests IRQs
> we don't use") common isr and napi are separated into separate tx isr
> and rx isr/napi, but still in rx napi tx events are handled. So removing
> the tx event handling in rx napi.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
