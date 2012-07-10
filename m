From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 07:40:47 -0700 (PDT)
Message-ID: <20120710.074047.1501226985962277049.davem@davemloft.net>
References: <1341924089.27035.7.camel@lb-tlvb-eilong.il.broadcom.com>
	<20120710.060616.2081630953053267615.davem@davemloft.net>
	<1341931085.27035.13.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab2GJOkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 10:40:49 -0400
In-Reply-To: <1341931085.27035.13.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 10 Jul 2012 17:38:05 +0300

> On Tue, 2012-07-10 at 06:06 -0700, David Miller wrote:
>> Why can't you turn CNIC off at the start, and if a CNIC user actually
>> arrives and is activated, reset the entire chip and put it into CNIC
>> mode?
> 
> Since the CNIC mode should not change under traffic, and since it is a
> shared HW attribute, we need to consider a scenario on which one
> interface is loaded and running in L2 only mode, and then on another
> interface the CNIC is required, but enabling it will affect the first
> interface that is already running.

If CNIC is off, the only effect for other users of the chips is
perhaps some dropped packets.  This is acceptable.

That is why I said you should only go from CNIC off to CNIC on,
and never the other way around.

I have yet to see a justification why you cannot implement this
properly, and my patience is completely exhausted on this issue.
