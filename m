From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2: Save statistics during reset.
Date: Sun, 17 Jan 2010 19:16:27 -0800 (PST)
Message-ID: <20100117.191627.21070197.davem@davemloft.net>
References: <1263749444-17072-1-git-send-email-mchan@broadcom.com>
	<1263749444-17072-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48125
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266Ab0ARDQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 22:16:18 -0500
In-Reply-To: <1263749444-17072-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 17 Jan 2010 09:30:44 -0800

> MTU changes, ring size changes, etc cause the chip to be reset and the
> statisctics flushed.  To keep track of the accumulated statistics, we
> add code to save the whole statistics block before reset.  We also
> modify the macros and statistics functions to return the sum of the
> saved and current counters.
> 
> Based on original patch by Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
