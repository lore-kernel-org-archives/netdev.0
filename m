From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix the rollback test in dev_change_name()
Date: Mon, 16 Nov 2009 02:49:36 -0800 (PST)
Message-ID: <20091116.024936.14048478.davem@davemloft.net>
References: <4AEB7BB1.9000901@gmail.com>
	<20091102.000549.114598716.davem@davemloft.net>
	<20091116093024.GA13115@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbZKPKtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:49:20 -0500
In-Reply-To: <20091116093024.GA13115@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 16 Nov 2009 09:30:24 +0000

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> net: Fix the rollback test in dev_change_name()
> 
> In dev_change_name() an err variable is used for storing the original
> call_netdevice_notifiers() errno (negative) and testing for a rollback
> error later, but the test for non-zero is wrong, because the err might
> have positive value as well - from dev_alloc_name(). It means the
> rollback for a netdevice with a number > 0 will never happen. (The err
> test is reordered btw. to make it more readable.)
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Ok.

Eric please give your signoff and I'll put this where it needs
to go.

Thanks.
