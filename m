From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected
 on CPU#0!)
Date: Fri, 22 Dec 2006 05:47:35 -0800
Message-ID: <458BE1F7.7020006@candelatech.com>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local> <20061222074209.GA2148@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40551 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838AbWLVNrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 08:47:49 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061222074209.GA2148@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Dec 22, 2006 at 08:13:08AM +0100, Jarek Poplawski wrote:
>> On 20-12-2006 03:13, Ben Greear wrote:
>>> This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
>>> active use.
>>>  From the backtrace, I am thinking this might be a generic problem, 
>>> however.
>>>
>>> Any ideas about what this could be?  It seems to be reproducible every 
>>> day or
> ...
>> If it doesn't help, I hope lockdep will be more
>> precise when you'll upgrade to 2.6.19 or higher.
> 
> ... or when you enable lockdep in 2.6.18 (I've
> forgotten it's there alredy!).

I thought I had it enabled, but perhaps I do not.  I'll double check that
as soon as I'm back in the office after Christmas vacation.

Thanks for looking at this!

Ben

> 
> Jarek P.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

