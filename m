From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bnx2x: Prevent FW assertion when using Vxlan
Date: Fri, 18 Dec 2015 16:34:55 -0500 (EST)
Message-ID: <20151218.163455.827875764896748316.davem@davemloft.net>
References: <1450428132-16697-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965379AbbLRVe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:34:57 -0500
In-Reply-To: <1450428132-16697-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 18 Dec 2015 10:42:12 +0200

> FW has a rare corner case in which a fragmented packet using lots
> of frags would not be linearized, causing the FW to assert while trying
> to transmit the packet.
> 
> To prevent this, we need to make sure the window of fragements containing
> MSS worth of data contains 1 BD less than for regular packets due to
> the additional parsing BD.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
