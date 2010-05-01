From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Fri, 30 Apr 2010 20:06:34 -0400
Message-ID: <1272672394.14499.1.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:43949 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077Ab0EAAGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 20:06:40 -0400
Received: by qyk13 with SMTP id 13so1093681qyk.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 17:06:39 -0700 (PDT)
In-Reply-To: <1272660000.2230.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-30 at 22:40 +0200, Eric Dumazet wrote:

> 
> I used your program, and with RPS off, I can get at most 220.000 pps
> with my "old" hardware. I dont understand how you can reach 700.000 pps
> with RPS off. Or is it with your Nehalem ?

Yes, Nehalem. 
RPS off is better (~700Kpp) than RPS on(~650kpps). Are you seeing the
same trend on the old hardware?

cheers,
jamal

