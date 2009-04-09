From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: 2.6.30-rc1: e1000: list_add corruption
Date: Thu, 09 Apr 2009 00:51:06 -0700 (PDT)
Message-ID: <20090409.005106.96791990.davem@davemloft.net>
References: <20090408.212040.184687004.davem@davemloft.net>
	<20090409071242.GA5515@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090409071242.GA5515-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 9 Apr 2009 07:12:42 +0000

> On 09-04-2009 06:20, David Miller wrote:
>> From: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Thu, 9 Apr 2009 08:16:00 +0400
>> 
>>> The host has two interfaces
>>> eth0 - e1000, eth1 - forcedeth.
>>> Both are not working after that messages.
>> 
>> It looks like the NAPI pending list is being modified in an illegal
>> state by forcedeth, and mid-stream to a list_del() an e1000 interrupt
>> comes in and this tries to schedule the e1000 NAPI context and we get
>> list corruption.
> 
> Good point! Feel free to send a patch. ;-)

A real shame, since I sent that analysis in hoping someone else
would do the rest of the digging and write the fix. :-/
