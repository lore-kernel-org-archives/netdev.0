From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Schedule/Destroy worker thread in
 probe()/remove() rather than open()/close()
Date: Wed, 27 Oct 2010 11:14:08 -0700 (PDT)
Message-ID: <20101027.111408.246543108.davem@davemloft.net>
References: <20101026090102.GA2460@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: somnath.kotur@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754199Ab0J0SNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:13:45 -0400
In-Reply-To: <20101026090102.GA2460@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>
Date: Tue, 26 Oct 2010 14:31:03 +0530

> When async mcc compls are rcvd on an i/f that is down (and so interrupts are disabled)
> they just lie unprocessed in the compl queue.The compl queue can eventually get filled
> up and cause the BE to lock up.The fix is to use be_worker to reap mcc compls when the
> i/f is down.be_worker is now launched in be_probe() and canceled in be_remove().
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>

Applied.
