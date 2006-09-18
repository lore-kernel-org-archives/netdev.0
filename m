From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Tue, 19 Sep 2006 02:51:23 +0400
Message-ID: <20060918225123.GA22150@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com> <20060918.003938.26278728.davem@davemloft.net> <450ED337.8000700@hp.com> <20060918204105.GA31333@ms2.inr.ac.ru> <450F0EA5.2020109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:29116 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030239AbWIRWvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 18:51:32 -0400
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <450F0EA5.2020109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> There isn't any sort of clever short-circuiting in loopback is there?

No, from all that I know.


> 									I 
> do like the convenience of testing things over loopback, but always fret 
> about not including drivers and actual hardware interrupts etc.

Well, if the test is right, it should show cost of redundant ACKs.


> Regardless, kudos for running the test.  The only thing missing is the 
> -c and -C options to enable the CPU utilization measurements which will 
> then give the service demand on a CPU time per transaction basis.  Or 
> was this a UP system that was taken to CPU saturation?

It is my notebook. :-) Of course, cpu consumption is 100%.
(Actally, netperf shows 100.10 :-))

I will redo test on a real network. What range of -b should I test?


> What i'm thinking about isn't so much about the latency

I understand.

Actually, I did those tests ages ago for a pure throughput case,
when nothing goes in the opposite direction. I did not find a difference
that time. And nobody even noticed that Linux sends ACKs _each_ small
segment for unidirectional connections for all those years. :-)

Alexey
