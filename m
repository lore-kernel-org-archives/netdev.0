From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Fri, 07 Nov 2014 15:26:57 -0800
Message-ID: <1415402817.13896.123.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx9kpW8Q4HgTyNE+O4yPRmMcOgjshrBfZXVnPu=EMVh4Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36174 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbaKGX1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 18:27:00 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so12927740igd.1
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 15:27:00 -0800 (PST)
In-Reply-To: <CA+mtBx9kpW8Q4HgTyNE+O4yPRmMcOgjshrBfZXVnPu=EMVh4Qg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-07 at 15:02 -0800, Tom Herbert wrote:

> Would it be better to get the incoming CPU before packet steering? Or
> maybe return this in addition to the CPU where ULP processes packet?

No packet steering : RFS is off.

If for some reason RPS is on (say NIC has a limited number of RX queues)
we'd like to have the cpu processing the packet in TCP stack for better
affinities.
