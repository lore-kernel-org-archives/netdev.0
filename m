From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] [RFC] allow admin/users to specify rto_min in	milliseconds
 rather than jiffies
Date: Wed, 05 Sep 2007 10:11:12 -0700
Message-ID: <46DEE330.40502@hp.com>
References: <200709042020.NAA29612@tardy.cup.hp.com> <20070905073801.2f12991b@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56168 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940AbXIESVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 14:21:54 -0400
In-Reply-To: <20070905073801.2f12991b@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 4 Sep 2007 13:20:47 -0700 (PDT)
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>>Build upon David Miller's initial patches to set the per-route rto_min
>>so users can specify the rto_min in the same units (milliseconds) in
>>which they are displayed.  This is desirable because asking users to
>>convert to and from jiffies themselves, when there can be different
>>values of HZ from system to system would be error prone.
>>
>>Signed-off-by: Rick Jones <rick.jones2@hp.com>
>>---
> 
> 
> The api in netlink should be in milliseconds rather than compensating
> in the application (iproute2).

In unrelated work I found myself using tc to setup some WAN emulation. 
There I noticed that one can specify times using a units suffix. So, one 
can say 100ms, 100us, or 100s.

That seems like a nice, friendly interface.  I've not looked yet to see 
if it was converting up in tc and then passing a consistent unit to the 
kernel, or if all the conversion was happening in the kernel.

rick jones
