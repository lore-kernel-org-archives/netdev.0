From: David Miller <davem@davemloft.net>
Subject: Re: [4/5][BNX2]: Fix occasional counter corruption on 5708.
Date: Mon, 04 Jun 2007 21:24:17 -0700 (PDT)
Message-ID: <20070604.212417.08667756.davem@davemloft.net>
References: <1181001668.5275.15.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, jd@disjunkt.com,
	cat@zip.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754561AbXFEEYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 00:24:03 -0400
In-Reply-To: <1181001668.5275.15.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 04 Jun 2007 17:01:08 -0700

> [BNX2]: Fix occasional counter corruption on 5708.
> 
> The statistics block DMA on 5708 can be messed up occasionally on the
> average of about once per hour.  If the user is reading the counters
> within one second after the corruption, the counters will be all
> messed up.  One second later, the counters will be ok again until the
> next corruption occurs.
> 
> The workaround is to disable the periodic statistics DMA.  Instead,
> we manually trigger the DMA once a second in bnx2_timer().  This
> manual trigger of the DMA avoids the problem.
> 
> As a consequence, we can only allow 0 or 1 second settings for
> ethtool -C statistics block.
> 
> Thanks to Jean-Daniel Pauget <jd@disjunkt.com> and
> CaT <cat@zip.com.au> for reporting this rare problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
