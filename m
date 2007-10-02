From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 14:32:55 -0700 (PDT)
Message-ID: <20071002.143255.57471247.davem@davemloft.net>
References: <20071002172002.GO17418@bitmover.com>
	<4702878B.4040102@hp.com>
	<20071002184032.GB29944@bitmover.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, torvalds@linux-foundation.org,
	wscott@bitmover.com, netdev@vger.kernel.org
To: lm@bitmover.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753585AbXJBVcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:32:55 -0400
In-Reply-To: <20071002184032.GB29944@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lm@bitmover.com (Larry McVoy)
Date: Tue, 2 Oct 2007 11:40:32 -0700

> I doubt it, the same test works fine in one direction and poorly in the other.
> Wouldn't the flow control squelch either way?

HW controls for these things are typically:

1) Generates flow control flames
2) Listens for them

So you can have flow control operational in one direction
and not the other.
