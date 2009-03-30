From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 23:25:28 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903302320180.15929@ask.diku.dk>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
 <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
 <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>
 <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com>
 <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk> <49D12E87.4090005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1182830231-1238448328=:15929"
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:52627 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbZC3VZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 17:25:36 -0400
In-Reply-To: <49D12E87.4090005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1182830231-1238448328=:15929
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT


On Mon, 30 Mar 2009, Eric Dumazet wrote:

> Jesper Dangaard Brouer a écrit :
>>
>> Against localhost I'm getting (not with applied patch):
>>
>>  1336.42 MB/sec on my AMD phenom X4 9950 Quad-Core Processor
>>
>>  1552.81 MB/sec on my Core i7 920 (4 physical cores, plus 4 threads)
>
> Strange results, compared to my E5420 (I thought i7 was faster ??)

I also though that i7 would be faster, but I think it can be explained by 
the i7 only has 4 real cores even though it shows 8 CPUs (due to 
hyperthreads).

>>  2274.53 MB/sec on my dual CPU Xeon E5420 (8 cores)

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-1182830231-1238448328=:15929--
