From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Sat, 20 Jun 2009 17:56:40 +0200
Message-ID: <4A3D06B8.6070107@trash.net>
References: <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <20090617110803.GA10175@elte.hu> <20090618052356.GA18722@elte.hu> <4A39D778.9020607@cosmosbay.com> <4A3A0D45.8090806@trash.net> <4A3A5599.4080906@trash.net> <20090620154716.GA12901@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756659AbZFTP45@vger.kernel.org>
In-Reply-To: <20090620154716.GA12901@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Patrick McHardy <kaber@trash.net> wrote:
> 
>> Ingo, could you please try whether this patch (combined with the 
>> last one) makes any difference? Enabling CONFIG_NETFILTER_DEBUG 
>> could also help.
> 
> Mind pushing it upstream, and i'll keep things monitored over the 
> week following when it hits upstream?
> 
> The reason is, the crash ratio is worse than 1:1000, it took a day 
> and a 1000 tests to trigger that one. I havent seen it after that.
> 
> So it's going to be a very slow observation and you shouldnt 
> serialize on me - giving you a 'it works' positive result will take 
> 10,000 random bootp tests or so - that's a week or longer. (it can 
> take a long time to hit that especially in the merge window when 
> there's a lot of various test failures that cause hickups in the 
> test stream.)

OK thanks, I'll push it upstream soon.

> ( Mailing me an upstream sha1 when all fixes in this area have hit 
>   upstream would certainly be welcome - i can use that as a 'no 
>   crashes expected in that area from that point on' flag day. )

Sure, will do.
