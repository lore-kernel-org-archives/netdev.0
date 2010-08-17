From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net sched: fix some kernel memory leaks
Date: Tue, 17 Aug 2010 15:14:45 -0700 (PDT)
Message-ID: <20100817.151445.59662752.davem@davemloft.net>
References: <1282025062.2487.696.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48209
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751433Ab0HQWO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 18:14:28 -0400
In-Reply-To: <1282025062.2487.696.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Aug 2010 08:04:22 +0200

> We leak at least 32bits of kernel memory to user land in tc dump,
> because we dont init all fields (capab ?) of the dumped structure.
> 
> Use C99 initializers so that holes and non explicit fields are zeroed.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks for fixing this Eric.
