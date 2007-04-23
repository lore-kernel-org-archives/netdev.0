From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 13:18:10 -0700 (PDT)
Message-ID: <20070423.131810.78710074.davem@davemloft.net>
References: <20070423130734.d3d90b20.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35019
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752387AbXDWUSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 16:18:04 -0400
In-Reply-To: <20070423130734.d3d90b20.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 23 Apr 2007 13:07:34 -0700

> The interesting bit is:
 ...
> I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
> didn't have time to investigate further.  So it's not some recent thing.

My initial reaction is that DNS responses are being lost or dropped
for some reason.

Please run tcpdump on the network while this machine comes up and
see if DNS requests and replies are going back and forth
correctly.

Also, please indicate what kind of network card is in this computer.

Thanks.
