From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7 net-2.6.26] [TIPC]: Enhance validation of format on
 incoming messages
Date: Tue, 15 Apr 2008 19:05:03 -0700 (PDT)
Message-ID: <20080415.190503.168600922.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-8-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753789AbYDPCFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:05:01 -0400
In-Reply-To: <1208288637-15304-8-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:57 -0400

> This patch ensures that TIPC properly handles incoming messages
> that have incorrect or unexpected formats.  Most significantly,
> it now ensures that each sl_buff has at least as much data as
> the message header indicates it should, and that the entire
> message header is stored contiguously; this prevents TIPC from
> accidentally accessing memory that is not part of the sk_buff.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied, thanks.
