From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch 2/2] Documentation/connector/cn_test.c: don't use gfp_any()
Date: Thu, 12 Feb 2009 01:10:25 +0300
Message-ID: <20090211221025.GA29015@2ka.mipt.ru>
References: <200902112127.n1BLRKcv031578@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, andi@firstfloor.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:46493 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754777AbZBKWQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 17:16:58 -0500
Content-Disposition: inline
In-Reply-To: <200902112127.n1BLRKcv031578@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2009 at 01:27:19PM -0800, akpm@linux-foundation.org (akpm@linux-foundation.org) wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> cn_test_timer_func() is a timer handler and can never use GFP_KERNEL -
> there's no point in using gfp_any() here.
> 
> Also, use setup_timer().
> 
> Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Andi Kleen <andi@firstfloor.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Looks good for the documentation update :)
Thank you.

-- 
	Evgeniy Polyakov
