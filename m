From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib: convert reader/writer to spinlock
Date: Tue, 08 Aug 2006 16:52:29 -0700 (PDT)
Message-ID: <20060808.165229.75503720.davem@davemloft.net>
References: <20060808110100.7fb24faf@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23181
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030343AbWHHXwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:52:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060808110100.7fb24faf@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 8 Aug 2006 11:01:00 -0700

> Ther is no point in using a more expensive reader/writer lock
> for a low contention lock like the fib_info_lock. The only
> reader case is in handling route redirects.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
