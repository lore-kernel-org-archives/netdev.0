From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 21:14:55 +0200
Message-ID: <20090423191455.GC2756@ami.dom.local>
References: <20090423184319.GB2756@ami.dom.local> <Pine.LNX.4.64.0904232103390.13488@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:35426 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759819AbZDWTRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 15:17:18 -0400
Received: by bwz7 with SMTP id 7so722663bwz.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 12:17:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0904232103390.13488@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 09:06:59PM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 23 Apr 2009, Jarek Poplawski wrote:
>
>> Radu Rendec wrote, On 04/23/2009 02:31 PM:
>>
>>> On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
>> ...
>>>> The HTB classify hash has a scalability issue in kernels below 2.6.26.
>>>> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you
>>>> using?
>>>
>>> I'm using 2.6.26, so I guess the fix is already there :(
>>
>> If Jesper meant the change of hash I can see it in 2.6.27 yet.
>
> I'm referring to:
>
>  commit f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2
>  Author: Patrick McHardy <kaber@trash.net>
>  Date:   Sat Jul 5 23:22:35 2008 -0700
>
>     net-sched: sch_htb: use dynamic class hash helpers
>
> Is there any easy git way to figure out which release this commit got  
> into?

I guess git-describe, but I prefer clicking at the "raw" (X-Git-Tag):
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2

Jarek P.
