From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Improve returned error codes
Date: Tue, 03 Jun 2008 16:37:01 -0700 (PDT)
Message-ID: <20080603.163701.121691161.davem@davemloft.net>
References: <20080526113240.GY20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753789AbYFCXhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:37:02 -0400
In-Reply-To: <20080526113240.GY20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 26 May 2008 13:32:40 +0200

> Make nlmsg_trim(), nlmsg_cancel(), genlmsg_cancel(), and nla_nest_cancel()
> void functions.
> 
> Return -EMSGSIZE instead of -1 if the provided message buffer
> is not big enough.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
