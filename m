From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] netpoll: Is it ok to share a single napi from several
 devs ?
Date: Mon, 30 Aug 2010 13:12:46 -0700
Message-ID: <20100830131246.25b16e8e@nehalam>
References: <1283107162.2297.32.camel@edumazet-laptop>
	<20100830064231.GA7060@ff.dom.local>
	<20100830085721.54c8c31b@nehalam>
	<20100830.095012.233695092.davem@davemloft.net>
	<20100830183620.GA3079@del.dom.local>
	<1283198356.2405.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46175 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab0H3UMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 16:12:48 -0400
In-Reply-To: <1283198356.2405.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Aug 2010 21:59:16 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> So everybody jumped on GRO, while my concern was more the napi->dev
> thing.
> 
> I pointed to gro because the commit was about gro, but gro was fine
> IMHO.
> 
> Are we sure netpoll is ok ?

Netpoll is dependent on napi->netdev but does not cause problems.
The sky2 driver doesn't expose netpoll on second port.
The second port has different net_device_ops without netpoll.


-- 
