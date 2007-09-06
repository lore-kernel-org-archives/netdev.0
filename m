From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] [RFC] allow admin/users to specify rto_min in	milliseconds
 rather than jiffies
Date: Thu, 06 Sep 2007 14:17:48 -0700
Message-ID: <46E06E7C.4000407@hp.com>
References: <200709042020.NAA29612@tardy.cup.hp.com> <20070905073801.2f12991b@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:55462 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932382AbXIFVSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 17:18:17 -0400
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

My understanding of the in-kernel rtnetlink code is far from complete, 
but it doesn't seem to have much in the way of provisions for unit 
conversion, which would suggest no nice suffix-based ui as in tc, and ip 
is already doing some massaging of units on the display side for a 
couple of the other parameters, so I'm at something of a loss.

rick jones
