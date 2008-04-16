From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7 net-2.6.26] [TIPC]: Use fast buffer cloning to
 improve performance
Date: Tue, 15 Apr 2008 19:02:38 -0700 (PDT)
Message-ID: <20080415.190238.267193692.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-6-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46861
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbYDPCCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:02:37 -0400
In-Reply-To: <1208288637-15304-6-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:55 -0400

> This patch causes TIPC to allocate fast clonable sk_buffs,
> rather than standard ones.  This speeds up the cloning
> operation done by the link code each time a message is sent
> off-node.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
