From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/core/dev.c:1344 __netif_schedule+0x26/0x76()
Date: Wed, 23 Jul 2008 14:07:34 -0700 (PDT)
Message-ID: <20080723.140734.28877846.davem@davemloft.net>
References: <200807231325.25672.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752858AbYGWVHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:07:33 -0400
In-Reply-To: <200807231325.25672.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Wed, 23 Jul 2008 13:25:25 -0700

> Testing a GIT build from last night ... after disabling I2C to avoid
> the oops-on-boot, I get warning that seems to have been introduced
> by network queue changes (see below).
> 
> What change to device initialization is needed remove this warning?

Just ignore it, I'm going to remove the warning today.

I was trying to sanitize how drivers make netif_*_queue() calls
but the problem is larger than I expected and the process will
be helped along if I write up some suitable replacement
infrastructure first.
