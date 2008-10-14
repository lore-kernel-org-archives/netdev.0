From: Donald Porter <porterde@cs.utexas.edu>
Subject: Re: e1000 softirq load balancing
Date: Tue, 14 Oct 2008 18:55:40 -0500
Message-ID: <2114C312-C2A8-487E-B35B-2AE9584AAD16@cs.utexas.edu>
References: <48F4ED7E.4070308@cs.utexas.edu> <20081014.125156.92616351.davem@davemloft.net> <48F52F43.9040201@cs.utexas.edu> <20081014.165109.199128881.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cs.utexas.edu ([128.83.139.10]:53358 "EHLO
	mail.cs.utexas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbYJNXzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 19:55:45 -0400
In-Reply-To: <20081014.165109.199128881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok.  That seems very reasonable.

So the behavior I am seeing is that I have 4 NICs, but all of the  
traffic is being funneled to 1-2 softirq handlers, despite the fact  
that the hardware interrupts are being delivered to 4 different CPUs.

Any tips on how to debug this?  Or perhaps there is some configuration  
step I am missing?

Thanks,
Don

On Oct 14, 2008, at 6:51 PM, David Miller wrote:

> From: Don Porter <porterde@cs.utexas.edu>
> Date: Tue, 14 Oct 2008 18:46:11 -0500
>
>> Would you mind giving me a bit of intuition why I can't have a 1:1
>> mapping of CPUs to NICs?
>
> I didn't say that.
>
> I said that without HW flow seperation support, you can only
> expect N cpus to be busy where N is the number of NICs you
> have.

