From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: fix hang in napi_disable
Date: Thu, 17 Nov 2011 21:44:13 -0500 (EST)
Message-ID: <20111117.214413.2080865348826584405.davem@davemloft.net>
References: <20111116234344.526517614@vyatta.com>
	<87r517w2z0.fsf@turtle.gmx.de>
	<20111117163735.0a16660b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab1KRCoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 21:44:19 -0500
In-Reply-To: <20111117163735.0a16660b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 17 Nov 2011 16:37:35 -0800

> If IRQ was never initialized, then calling napi_disable() would hang.
> Add more bookkeeping to track whether IRQ was ever initialized.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to 'net'.
