From: Rick Jones <rick.jones2@hp.com>
Subject: Re: HTB vs CoDel performance
Date: Wed, 19 Sep 2012 10:00:32 -0700
Message-ID: <5059FA30.8070209@hp.com>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com> <1347961511.26523.216.camel@edumazet-glaptop> <CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com> <1347963353.26523.224.camel@edumazet-glaptop> <CAF1ivSYQiXBOtzZdDUKEqWWsW5cgLgSkLs88Dvkppb02yN6wTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	networking <netdev@vger.kernel.org>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:23614 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755346Ab2ISRAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:00:35 -0400
In-Reply-To: <CAF1ivSYQiXBOtzZdDUKEqWWsW5cgLgSkLs88Dvkppb02yN6wTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2012 06:26 PM, Lin Ming wrote:
> On Tue, Sep 18, 2012 at 6:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Are you really cpu limited ? You might hit some clocks artifacts.
>
> Did you mean the cpu speed? It's an ARMv5 processor.
> BogoMIPS	: 1196.03

At the risk of typing into Eric's keyboard, he was asking if you were 
saturating the CPU - was it getting to 100% utilization, that sort of thing.

>> rate limiting to 1Gbps probably need high resolution timers.
>
> High resolution timer is enabled.

When you are running your tests, what sort of CPU utilization do you see 
on the CPU of your router with HTB on vs off.  Some "quick and dirty" 
netperf tests on an Centrino-based laptop suggested that as an end 
system at least, HTB at 1 GbE (using your tc commands) increases service 
demand (what netperf calculates as CPU consumed per unit of work 
performed) ~15% for bulk transfer (netperf TCP_STREAM) and ~18% for 
small packet request/response (TCP_RR).

rick jones
