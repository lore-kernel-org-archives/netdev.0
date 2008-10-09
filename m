From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: remove over-paranoid queue number
 modulus
Date: Thu, 09 Oct 2008 14:31:52 -0700 (PDT)
Message-ID: <20081009.143152.07519233.davem@davemloft.net>
References: <48EE10C5.5030609@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42137
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755614AbYJIVcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:32:17 -0400
In-Reply-To: <48EE10C5.5030609@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Thu, 09 Oct 2008 16:10:13 +0200

> No need to modulus the queue number in ->hard_start_xmit() since the
> core is going to do that for you modulus ->real_num_tx_queues.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied, thank you.
