From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 21:47:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904232136040.13796@ask.diku.dk>
References: <20090423184319.GB2756@ami.dom.local> <Pine.LNX.4.64.0904232103390.13488@ask.diku.dk>
 <20090423191455.GC2756@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Radu Rendec <radu.rendec@ines.ro>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, git@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <git-owner@vger.kernel.org>
In-Reply-To: <20090423191455.GC2756@ami.dom.local>
Sender: git-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Apr 2009, Jarek Poplawski wrote:

> On Thu, Apr 23, 2009 at 09:06:59PM +0200, Jesper Dangaard Brouer wrote:
>> On Thu, 23 Apr 2009, Jarek Poplawski wrote:
>>
>>> Radu Rendec wrote, On 04/23/2009 02:31 PM:
>>>
>>>> On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
>>> ...
>>>>> The HTB classify hash has a scalability issue in kernels below 2.6.26.
>>>>> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you
>>>>> using?
>>>>
>>>> I'm using 2.6.26, so I guess the fix is already there :(
>>>
>>> If Jesper meant the change of hash I can see it in 2.6.27 yet.
>>
>> I'm referring to:
>>
>>  commit f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2
>>  Author: Patrick McHardy <kaber@trash.net>
>>  Date:   Sat Jul 5 23:22:35 2008 -0700
>>
>>     net-sched: sch_htb: use dynamic class hash helpers
>>
>> Is there any easy git way to figure out which release this commit got
>> into?
>
> I guess git-describe, but I prefer clicking at the "raw" (X-Git-Tag):
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff_plain;h=f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2

I think I prefer the command line edition "git-describe".  But it seems 
that the two approaches gives a different results.
(Cc'ing the git mailing list as they might know the reason)

  git-describe f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2
  returns "v2.6.26-rc8-1107-gf4c1f3e"

  While you URL returns: "X-Git-Tag: v2.6.27-rc1~964^2~219"

I also did a:
"git log v2.6.26..v2.6.27 | grep f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2"
commit f4c1f3e0c59be0e6566d9c00b1d8b204ffb861a2

To Radu: The change I talked about is in 2.6.27, so you should try that 
kernel on you system.

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
