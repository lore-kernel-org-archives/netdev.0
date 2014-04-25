From: =?UTF-8?B?U3Zlbm5pbmcgU8O4cmVuc2Vu?= <sss@secomea.com>
Subject: Re: [PATCH] net: guard against coalescing packets from buggy network
 drivers
Date: Fri, 25 Apr 2014 18:01:55 +0200
Message-ID: <535A86F3.5010602@secomea.com>
References: <535A78ED.3020309@secomea.com> <1398440595.29914.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398440595.29914.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 25-04-2014 17:43, Eric Dumazet wrote:
>
> If you want a debugging patch, this should happen way before TCP stack
> or even IP stack.
>
> Say you want to use this buggy driver on a router, this code path will
> never bit hit.
>
You are right, of course, there are more effective ways to catch buggy 
drivers.
But they will probably also be much more expensive.
This one is very cheap, being in a relatively cold path, especially 
compared to the memcpy in the same path.

Svenning
