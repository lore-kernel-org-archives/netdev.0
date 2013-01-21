From: David Miller <davem@davemloft.net>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Sun, 20 Jan 2013 23:21:22 -0500 (EST)
Message-ID: <20130120.232122.1798689273842981732.davem@davemloft.net>
References: <20130119044957.GA25395@dcvr.yhbt.net>
	<1358574847.3464.422.camel@edumazet-glaptop>
	<1358575996.3464.447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: normalperson@yhbt.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, w@1wt.eu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3AUEVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 23:21:24 -0500
In-Reply-To: <1358575996.3464.447.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Jan 2013 22:13:16 -0800

> On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:
> 
>> 
>> Hmm, this might be already fixed in net-next tree, could you try it ?
>> 
> 
> Yes, running your program on net-next seems OK.
> 
> David, we need the two following commits.

Tossed into 'net' and queued up for -stable, thanks.
