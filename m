From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:10:39 -0700 (PDT)
Message-ID: <20100926.151039.189687862.davem@davemloft.net>
References: <20100926174014.GA12373@1wt.eu>
	<1285526115.2530.12.camel@edumazet-laptop>
	<20100926184914.GC12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757592Ab0IZWKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 18:10:19 -0400
In-Reply-To: <20100926184914.GC12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


TCP is a reliable transport.

If you choose to close before the data from the peer has been fully
received, you've subverted the reliability of the data transport.

Reset is the only reasonable action in this situation.
