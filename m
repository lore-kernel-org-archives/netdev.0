From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 18:55:41 -0700 (PDT)
Message-ID: <20151029.185541.1425854866063854493.davem@davemloft.net>
References: <20151029160131.GA18961@netbsd.org>
	<56324625.9000803@oracle.com>
	<20151029170748.GG22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan.Burlison@oracle.com, dholland-tech@netbsd.org,
	Casper.Dik@oracle.com, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbbJ3Biy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 21:38:54 -0400
In-Reply-To: <20151029170748.GG22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 29 Oct 2015 17:07:48 +0000

> _IF_ you are doing that kind of "close a descriptor under other threads"
> thing, you need to inform the potentially affected threads anyway, and
> you'd better not rely on them being currently in kernel mode.

+1
