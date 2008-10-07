From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix possible double-ack w/ user dma
Date: Tue, 07 Oct 2008 15:31:50 -0700 (PDT)
Message-ID: <20081007.153150.253434731.davem@davemloft.net>
References: <0298B280-C0E8-4A30-90B6-DD25A4054CF0@engin.umich.edu>
	<DCA6A06C-CE49-453F-91D8-23A6C4187FD6@engin.umich.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saidi@engin.umich.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754967AbYJGWcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:32:15 -0400
In-Reply-To: <DCA6A06C-CE49-453F-91D8-23A6C4187FD6@engin.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ali Saidi <saidi@engin.umich.edu>
Date: Sun, 28 Sep 2008 22:45:51 -0500

> I attached a broken patch. This one is correct, although there are
> probably other ways to fix the issue.

Seems safe enough, in that only NET_DMA can see a behavior change, and the
patch does in fact seem correct.

Applied to net-2.6, thanks.
