From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove useless prefetch() call
Date: Fri, 20 Mar 2009 01:36:11 -0700 (PDT)
Message-ID: <20090320.013611.67498837.davem@davemloft.net>
References: <49C354B5.3060404@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42886
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752292AbZCTIgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:36:24 -0400
In-Reply-To: <49C354B5.3060404@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 20 Mar 2009 09:32:53 +0100

> There is no point to use prefetch() call here.
> start_xmit() is a function like others...
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Yes but the operation pointer might not be in the CPU
cache at this time?

And if it's not we can get it into the cpu whilst we do
other processing, such as the dev_queue_xmit_nit() stuff.
