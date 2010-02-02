From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: avoid spinlock in get_acqseq()
Date: Tue, 02 Feb 2010 15:59:24 -0800 (PST)
Message-ID: <20100202.155924.219619994.davem@davemloft.net>
References: <1264773952.3184.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45572
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755945Ab0BBX7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 18:59:10 -0500
In-Reply-To: <1264773952.3184.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2010 15:05:52 +0100

> Use atomic_inc_return() in get_acqseq() to avoid taking a spinlock
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
