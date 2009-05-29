From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: dont update dev->trans_start in 10GB
 drivers
Date: Fri, 29 May 2009 01:47:26 -0700 (PDT)
Message-ID: <20090529.014726.173041259.davem@davemloft.net>
References: <4A1E208D.2020106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756883AbZE2Ir0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:47:26 -0400
In-Reply-To: <4A1E208D.2020106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2009 07:26:37 +0200

> Followup of commits 9d21493b4beb8f918ba248032fefa393074a5e2b
> and 08baf561083bc27a953aa087dd8a664bb2b88e8e
> (net: tx scalability works : trans_start)
> (net: txq_trans_update() helper)
> 
> Now that core network takes care of trans_start updates, dont do it
> in drivers themselves, if possible. Multi queue drivers can
> avoid one cache miss (on dev->trans_start) in their start_xmit()
> handler.
> 
> Exceptions are NETIF_F_LLTX drivers (vxge & tehuti)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
