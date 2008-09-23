From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Mon, 22 Sep 2008 22:16:58 -0700 (PDT)
Message-ID: <20080922.221658.221283630.davem@davemloft.net>
References: <20080921095705.GA2551@ami.dom.local>
	<20080921.031829.86500526.davem@davemloft.net>
	<20080921111551.GB2551@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751124AbYIWFRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:17:16 -0400
In-Reply-To: <20080921111551.GB2551@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 21 Sep 2008 13:15:51 +0200

> That's why I think you should reconsider this simple solution for now,
> until somebody proves this is wrong or something else is better.

Ok, that sounds reasonable.  I've added those three patches to net-next-2.6
and will push those out after some build tests.
