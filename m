From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add a statistics counter for tx hash miss
Date: Mon, 21 Jul 2008 09:33:30 -0700 (PDT)
Message-ID: <20080721.093330.153507902.davem@davemloft.net>
References: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
	<1216630088-10328-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753659AbYGUQda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:33:30 -0400
In-Reply-To: <1216630088-10328-2-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 21 Jul 2008 10:48:08 +0200

> Add a counter for the case when the TX hash function doesn't work.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

This is very much not an IPV4 protocol statistic.

I understand your desire to export this information, but
as easy as this method is it's not the right way.
