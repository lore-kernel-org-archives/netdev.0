From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Check num sacks in SACK fast path
Date: Sun, 04 Feb 2007 23:38:03 -0800 (PST)
Message-ID: <20070204.233803.97293382.davem@davemloft.net>
References: <20070202144116.26863.3722.sendpatchset@galon.ev-en.org>
	<20070202144127.26863.97696.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752769AbXBEHiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 02:38:03 -0500
In-Reply-To: <20070202144127.26863.97696.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Fri, 02 Feb 2007 16:41:27 +0200

> We clear the unused parts of the SACK cache, This prevents us from mistakenly
> taking the cache data if the old data in the SACK cache is the same as the data
> in the SACK block. This assumes that we never receive an empty SACK block with
> start and end both at zero.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

I've applied this one too, thanks a lot.
