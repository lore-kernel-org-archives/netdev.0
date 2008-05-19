From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5 net-next-2.6] [TIPC]: Fix bug in topology server
 byte swapping routine
Date: Mon, 19 May 2008 13:30:34 -0700 (PDT)
Message-ID: <20080519.133034.190514274.davem@davemloft.net>
References: <1210702665-5012-1-git-send-email-allan.stephens@windriver.com>
	<1210702665-5012-4-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756717AbYESUaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 16:30:39 -0400
In-Reply-To: <1210702665-5012-4-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 13 May 2008 14:17:43 -0400

> This patch fixes TIPC's topology server so that it does byte swapping
> correctly when endianness conversion is required.  (Note: This bug only
> impacted an application if it issues a subscription request to a
> topology server on another node, rather than the server on it's own
> node; since the topology server is normally not accessible by off-node
> applications, most TIPC applications were not impacted by the bug.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
