From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 16:13:23 -0700 (PDT)
Message-ID: <20080922.161323.108280715.davem@davemloft.net>
References: <48D81A95.5080207@redhat.com>
	<20080922.152615.215876787.davem@davemloft.net>
	<48D82378.4000306@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752687AbYIVXNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 19:13:35 -0400
In-Reply-To: <48D82378.4000306@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>
Date: Mon, 22 Sep 2008 19:00:08 -0400

> Could you please point me to an example of a connection parameter
> that gets tuned and cached this way, so I can experiment with it?

You'll find tons of them in tcp_update_metrics().
