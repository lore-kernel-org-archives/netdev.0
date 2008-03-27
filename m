From: David Miller <davem@davemloft.net>
Subject: Re: O(n^2) or worse ? cat /proc/net/tcp
Date: Thu, 27 Mar 2008 14:28:32 -0700 (PDT)
Message-ID: <20080327.142832.15191443.davem@davemloft.net>
References: <20080323224307.GL3700@mea-ext.zmailer.org>
	<20080323.162021.184196552.davem@davemloft.net>
	<20080327114911.GT3700@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.aarnio@zmailer.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46521
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755154AbYC0V2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:28:32 -0400
In-Reply-To: <20080327114911.GT3700@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Aarnio <matti.aarnio@zmailer.org>
Date: Thu, 27 Mar 2008 13:49:11 +0200

> Odd..  Another machine with slightly older kernel is definitely swifter
> although it clocks less than half of the bogomips..

The machine with the faster cpu likely has much more memory,
thus the hash tables allocated are much larger, thus the
table scan is significantly more expensive.
