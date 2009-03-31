From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Tue, 31 Mar 2009 13:35:05 -0700
Message-ID: <49D27E79.5030404@hp.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>	<49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>	<Pine.LNX.4.64.0903302131390.13325@ask.diku.dk>	<49D12387.20507@cosmosbay.com>	<Pine.LNX.4.64.0903302224120.13385@ask.diku.dk>	<49D12E87.4090005@cosmosbay.com>	<Pine.LNX.4.64.0903312145130.2954@ask.diku.dk> <49D27BD9.4030503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:3925 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbZCaUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:35:09 -0400
In-Reply-To: <49D27BD9.4030503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
>>A note to Rick, the process "netperf" would use 100% CPU time and
>>"netserver" would only use 70%.

Thanks.  That makes a decent quantity of sense for a unidirectional test I 
suppose.  If you get bored you might see what happens with a burst 
request/response test.

./configure --enbable-burst
make netperf
netperf -T 0,2 -t TCP_RR -c -C -- -b 64 -D

altering the parms to either -T or -b as you find necessary/desireable.

rick
