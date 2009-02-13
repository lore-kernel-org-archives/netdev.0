From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] Documentation/connector/cn_test.c: don't use
 gfp_any()
Date: Thu, 12 Feb 2009 16:47:10 -0800 (PST)
Message-ID: <20090212.164710.99426054.davem@davemloft.net>
References: <200902112127.n1BLRKcv031578@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@firstfloor.org, johnpol@2ka.mipt.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754420AbZBMArQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:47:16 -0500
In-Reply-To: <200902112127.n1BLRKcv031578@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 11 Feb 2009 13:27:19 -0800

> cn_test_timer_func() is a timer handler and can never use GFP_KERNEL -
> there's no point in using gfp_any() here.
> 
> Also, use setup_timer().
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
