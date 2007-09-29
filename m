From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.23-rc[68]-mm: network hangs
Date: Sat, 29 Sep 2007 02:35:10 -0700 (PDT)
Message-ID: <20070929.023510.112596666.davem@davemloft.net>
References: <46FD5A82.9070505@free.fr>
	<20070929013106.4f84320d.akpm@linux-foundation.org>
	<46FE193E.60200@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: laurent.riffard@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752588AbXI2JfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 05:35:10 -0400
In-Reply-To: <46FE193E.60200@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Laurent Riffard <laurent.riffard@free.fr>
Date: Sat, 29 Sep 2007 11:22:06 +0200

> Could a router problem prevent "ping 127.0.0.1" from working ?

Two things that are new and could cause these problems:

1) We dynamically allocate the loopback device now.

2) We have the network namespace stuff.

Another change in this area is that we do routing cache
garbage collection from a workqueue instead of a timer
but that was a pretty straightforward transformation so
it is not high on my list of "suspects".
