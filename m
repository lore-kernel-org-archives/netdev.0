From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 21:06:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904232103390.13488@ask.diku.dk>
References: <20090423184319.GB2756@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:48070 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbZDWTHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 15:07:07 -0400
In-Reply-To: <20090423184319.GB2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Apr 2009, Jarek Poplawski wrote:

> Radu Rendec wrote, On 04/23/2009 02:31 PM:
>
>> On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
> ...
>>> The HTB classify hash has a scalability issue in kernels below 2.6.26.
>>> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you
>>> using?
>>
>> I'm using 2.6.26, so I guess the fix is already there :(
>
> If Jesper meant the change of hash I can see it in 2.6.27 yet.

I'm referring to:

  commit f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2
  Author: Patrick McHardy <kaber@trash.net>
  Date:   Sat Jul 5 23:22:35 2008 -0700

     net-sched: sch_htb: use dynamic class hash helpers

Is there any easy git way to figure out which release this commit got 
into?

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
