From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] KS8695: update ksp->next_rx_desc_read at the end
 of rx loop
Date: Fri, 19 Mar 2010 22:44:16 -0700 (PDT)
Message-ID: <20100319.224416.246517496.davem@davemloft.net>
References: <1268754720.3094.55.camel@edumazet-laptop>
	<f69abfc31003170239k2d64aa8bgbe3f3ae59a074a05@mail.gmail.com>
	<f69abfc31003170240u717283egf2c66adfaaa9aca7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39177
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751154Ab0CTFny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 01:43:54 -0400
In-Reply-To: <f69abfc31003170240u717283egf2c66adfaaa9aca7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>
Date: Wed, 17 Mar 2010 10:40:10 +0100

> KS8695: update ksp->next_rx_desc_read at the end of rx loop
> 
> There is no need to adjust the next rx descriptor after each packet,
> so do it only once at the end of the routine.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Applied.
