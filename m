From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Tue, 30 Sep 2008 06:58:52 -0700 (PDT)
Message-ID: <20080930.065852.116510157.davem@davemloft.net>
References: <20080930063231.GA4792@ff.dom.local>
	<48E212FF.1060409@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	dada1@cosmobay.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbYI3N7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 09:59:05 -0400
In-Reply-To: <48E212FF.1060409@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Tue, 30 Sep 2008 13:52:31 +0200

> BTW, in the past (last year) dst_gc_task() was run as a timer
> handler and this situation (deadlock with linkwatch_event())
> couldn't occur.

September 12th to be exact :-)  That's when Eric Dumazet's
change went in:

commit 86bba269d08f0c545ae76c90b56727f65d62d57f
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Sep 12 14:29:01 2007 +0200

    [PATCH] NET : convert IP route cache garbage collection from softirq processing to a workqueue


But this change went into 2.6.24, so I wonder why it's taken
so long to hit this.
