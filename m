From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/iucv: use explicit clean up labels in iucv_init()
Date: Mon, 28 Nov 2016 11:24:33 -0500 (EST)
Message-ID: <20161128.112433.295947046706527102.davem@davemloft.net>
References: <20161124091046.hixy3j4ibt7xzezr@linutronix.de>
        <20161124141415.llqki5vo7nqdusqv@linutronix.de>
        <20161124161013.dukr42y2nwscosk6@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, tglx@linutronix.de,
        linux-kernel@vger.kernel.org, rt@linutronix.de,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932406AbcK1QYf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:24:35 -0500
In-Reply-To: <20161124161013.dukr42y2nwscosk6@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 24 Nov 2016 17:10:13 +0100

> Ursula suggested to use explicit labels for clean up in the error path
> instead of one `out_free' label which handles multiple exits.
> Since the previous patch got already applied, here is a follow up patch.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

"Previous patch" doesn't tell readers anything specific enough to identify
the change you are referring to.  This will be even more true years down
the line if someone tries to read this commit and figure out what you
are referring to.

We have a standard mechanism to refer to commits, via SHA1_ID and commit
header line text, please use it.

Thank you.
