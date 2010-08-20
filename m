From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 18:20:32 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com> <1282321023.2484.285.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282321023.2484.285.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-08-20 18:17, Eric Dumazet wrote:
>> +	if (unlikely(!nf_conntrack_hash_rnd)) {
>> +		unsigned int rand;
>> +
>> +		/* Why not initialize nf_conntrack_rnd in a "init()" function ?
>> +		 * Because there isn't enough entropy when system initializing,
>> +		 * and we initialize it as late as possible. */
>
>This patch is fine but a fine multi line comment is :
>	/* Some
>	 * fine
>	 * comment
>	 */

Actually,

	/*
	 * Some
	 */

But that's in CodingStyle already. Always a good read, even if reread.
