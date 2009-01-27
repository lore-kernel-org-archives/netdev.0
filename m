From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 14:29:33 -0800
Message-ID: <497F8ACD.2050203@hp.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net>	<497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com>	<497F5F86.9010101@hp.com> <497F87E7.2000304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F87E7.2000304@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Thanks for the report
> 
> If you have so much contention on spinlocks, maybe hash function is not 
> good at all...
> 
> hash = (unsigned long)ct;
> hash ^= hash >> 16;
> hash ^= hash >> 8;
> 
> I ass-u-me you compiled your kernel with NR_CPUS=32 ?

I believe so - CONFIG_NR_CPUS in .config is 64 anyway.  If there is a more 
definitive place to check I'd be happy to look.

rick

