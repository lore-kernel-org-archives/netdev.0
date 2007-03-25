From: David Miller <davem@davemloft.net>
Subject: Re: [IPv4] fib: Fix out of bound access of fib_props[]
Date: Sat, 24 Mar 2007 20:33:39 -0700 (PDT)
Message-ID: <20070324.203339.71087299.davem@davemloft.net>
References: <20070324153435.GE521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39144
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932279AbXCYDdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 23:33:39 -0400
In-Reply-To: <20070324153435.GE521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 24 Mar 2007 16:34:36 +0100

> Fixes a typo which caused fib_props[] to have the wrong size
> and makes sure the value used to index the array which is
> provided by userspace via netlink is checked to avoid out of
> bound access.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
