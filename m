From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 4 Feb 2010 19:44:38 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002041944120.30159@obet.zrqbmnf.qr>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr> <4B6ADA3A.7040201@trash.net> <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr> <4B6ADFFB.4050407@trash.net> <alpine.LSU.2.01.1002041743360.21982@obet.zrqbmnf.qr>
 <4B6AFAA1.5080703@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6AFAA1.5080703@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-02-04 17:49, Patrick McHardy wrote:
>Jan Engelhardt wrote:
>>> The kernel also forbids ".".
>> 
>> My first thought was the same, but:
>> 
>> a) Interestingly, it does not prohibit '.'
>> 
>> 	ip tunnel add foo0.3 mode sit local 1.2.3.4 remote 5.6.7.8
>> 
>> b) The '.' is to be seen as valid as far as xtables.c goes, so
>>    as to match VLAN interfaces.
>
>Ah of course, its only invalid at the beginning of the name.
>
Nope:

19:44 borg:/home/jengelh # ip tunnel add .3 mode sit local 1.2.3.6 remote
5.6.7.7
19:44 borg:/home/jengelh # ip a
17: .3: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN 
    link/sit 1.2.3.6 peer 5.6.7.7
