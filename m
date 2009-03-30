From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 22:34:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903302224120.13385@ask.diku.dk>
References: <20090218051906.174295181@vyatta.com> <20090218052747.679540125@vyatta.com>
 <499BDB5D.2050105@trash.net> <499C1894.7060400@cosmosbay.com>
 <49CE568A.9090104@cosmosbay.com> <49D11635.2050809@hp.com>
 <Pine.LNX.4.64.0903302131390.13325@ask.diku.dk> <49D12387.20507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-68988457-1238445254=:13385"
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49D12387.20507@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-68988457-1238445254=:13385
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Mon, 30 Mar 2009, Eric Dumazet wrote:

> Jesper Dangaard Brouer a écrit :
>>
>>> Eric Dumazet wrote:
>>>>  "tbench 8" results on my 8 core machine (32bit kernel, with
>>>>  conntracking on) : 2319 MB/s instead of 2284 MB/s
>>
>> How do you achieve this impressing numbers?
>> Is it against localhost? (10Gbit/s is max 1250 MB/s)
>>
>
> tbench is a tcp test on localhost yes :)

I see!

Using a Sun 10GbE NIC I was only getting a throughput of 556.86 MB/sec 
with 64 procs (between an AMD Phenom X4 and a Core i7).  (Not tuned multi 
queues yet ...)

Against localhost I'm getting (not with applied patch):

  1336.42 MB/sec on my AMD phenom X4 9950 Quad-Core Processor

  1552.81 MB/sec on my Core i7 920 (4 physical cores, plus 4 threads)

  2274.53 MB/sec on my dual CPU Xeon E5420 (8 cores)


> Good to test tcp stack without going to NIC hardware

Yes true, but this also stresses the process scheduler, I'm seeing around 
800.000 context switches per sec on the Dual CPU Xeon system.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-68988457-1238445254=:13385--
