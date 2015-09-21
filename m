From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] iptunnel: make rx/tx bytes counters consistent
Date: Sun, 20 Sep 2015 22:37:49 -0700 (PDT)
Message-ID: <20150920.223749.1379178493985547245.davem@davemloft.net>
References: <1442569661-5528-1-git-send-email-nicolas.dichtel@6wind.com>
	<20150920.223513.1872161134519661761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755844AbbIUFhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:37:50 -0400
In-Reply-To: <20150920.223513.1872161134519661761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 20 Sep 2015 22:35:13 -0700 (PDT)

>> After the patch:
>> $ ping -c1 192.168.0.121 ; ip -s l ls dev gre1
>> PING 192.168.0.121 (192.168.0.121) 56(84) bytes of data.
>> 64 bytes from 192.168.0.121: icmp_req=1 ttl=64 time=2.95 ms
>> 
>> --- 192.168.0.121 ping statistics ---
>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>> rtt min/avg/max/mdev = 2.955/2.955/2.955/0.000 ms

BTW, when you includ PING output in a commit message like this
it really makes things difficult.

"---" denotes end of the commit as far as tools like "git am"
are concerned.

I happened to notice this time and fix up the commit messages by hand,
but it'd be much better if it weren't left up to chance like that.

Thanks.
