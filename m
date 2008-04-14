From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [TIPC]: Eliminate port pointer in TIPC
 socket object
Date: Sun, 13 Apr 2008 21:32:31 -0700 (PDT)
Message-ID: <20080413.213231.201255969.davem@davemloft.net>
References: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750808AbYDNEca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:32:30 -0400
In-Reply-To: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Fri,  4 Apr 2008 16:59:45 -0400

> This patch eliminates the "port" pointer in the TIPC socket
> object by storing this info in the (previously unused)
> sk_user_data field of the standard sock structure.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

The sk_user_data member is used by network filesystem layers to store
data local to such layers, and thus be able to not conflict with
private data used by protocols.

Therefore, it should not be used by the protocols.
