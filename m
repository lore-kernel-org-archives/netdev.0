From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: sched: fix unsued cpu variable
Date: Sat, 13 Sep 2014 11:25:15 -0700
Message-ID: <54148C0B.8040500@intel.com>
References: <20140913181352.32293.58637.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57605 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbaIMSZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 14:25:59 -0400
In-Reply-To: <20140913181352.32293.58637.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2014 11:13 AM, John Fastabend wrote:
> kbuild test robot reported an unused variable cpu in cls_u32.c
> after the patch below. This happens when PERF and MARK config
> variables are disabled
> 
> commit 459d5f626da75573e985a7197b0919c3b143146c
> Author: John Fastabend <john.fastabend@gmail.com>
> Date:   Fri Sep 12 20:08:47 2014 -0700
> 
>     net: sched: make cls_u32 per cpu
> 
> One way to fix this is to use separate variables for perf
> and mark and define the cpu variable inside the ifdef
> logic.
> 
> I don't really like this though so I'm wondering if I can
> clean up the ifdef/endif logic to make this easier to read.
> So RFC patch until I convince myself there isn't a better
> way. Thought it might be worth sending out in case someone
> else has an idea.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

kbuild robot kicked me another warning I missed I'll send out
a couple patches tonight or tomorrow morning to resolve them.

Thanks,
John
