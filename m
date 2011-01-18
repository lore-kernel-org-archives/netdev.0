From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [patch 2/4] ipset: make IPv4 and IPv6 address handling similar
Date: Tue, 18 Jan 2011 21:25:48 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101182121310.19007@obet.zrqbmnf.qr>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.498399684@eitzenberger.org> <alpine.DEB.2.00.1101182116150.28203@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: holger@eitzenberger.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1101182116150.28203@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2011-01-18 21:18, Jozsef Kadlecsik wrote:
>On Tue, 18 Jan 2011, holger@eitzenberger.org wrote:
>
>> While the following works for AF_INET:
>> 
>>  ipset add foo 192.168.1.1/32
>> 
>> this does not work for AF_INET6:
>> 
>>  ipset add foo6 20a1:1:2:3:4:5:6:7/128
>>  ipset v5.2: Syntax error: plain IP address must be supplied: 20a1:1:2:3:4:5:6:7/128
>
>Yeah, the usual issue: should IPv4/32 and IPv6/128 be handled as a plain 
>IPv4/v6 address when the manual says "enter a plain IPv4/v6 address" :-).

(Assuming this was a question, heuristically based on the word order
you used:) I don't think so. iptables, resp. its modules, do not
allow that either.
