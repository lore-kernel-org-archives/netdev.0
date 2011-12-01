From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 06/10] e1000e: Support for byte queue limits
Date: Thu, 01 Dec 2011 12:48:58 -0500 (EST)
Message-ID: <20111201.124858.1240854874296338456.davem@davemloft.net>
References: <20111129130137.000009ce@unknown>
	<CA+mtBx-8AzEyUc3GVD+mEQoqUZeaB9hjSJonRW_SjOQaTx51mQ@mail.gmail.com>
	<1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab1LARtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 12:49:03 -0500
In-Reply-To: <1322734334.2335.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 11:12:14 +0100

> OK, as stated on your other thread, its obvious this driver (and
> probably other intel drivers) made assumptions that are now obsolete,
> since skb head can contain some data payload, not only (MAC+IP+TCP)
> headers.

They were always wrong assumptions even before your patch Eric.

Any Netfilter or similar module can pull some data into the linear
area before the driver sees the packet on transmit.
