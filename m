From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 04:10:18 -0700 (PDT)
Message-ID: <20070912.041018.35029512.davem@davemloft.net>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
	<20070912100054.GA3649@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:56859
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967027AbXILLLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:11:06 -0400
In-Reply-To: <20070912100054.GA3649@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 12 Sep 2007 11:00:54 +0100

> Can you please et rid of this useless struct?  It just complicates
> the code and means we can't use the proper DEFINE_SPINLOCK initializer.

As long as the linker can move global variables around we need
to do things like this to keep objects together when that's
what we want.

So it's not really useless, but perhaps deserves a comment.
