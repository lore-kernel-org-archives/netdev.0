From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 13:52:43 -0700 (PDT)
Message-ID: <20090319.135243.51567158.davem@davemloft.net>
References: <49C1C09E.8050405@novell.com>
	<20090318.223806.123468340.davem@davemloft.net>
	<49C23DB9.6000905@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	pmullaney@novell.com
To: ghaskins@novell.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <49C23DB9.6000905@novell.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory Haskins <ghaskins@novell.com>
Date: Thu, 19 Mar 2009 08:42:33 -0400

> David Miller wrote:
> > From: Gregory Haskins <ghaskins@novell.com>
> > Date: Wed, 18 Mar 2009 23:48:46 -0400
> >
> >   
> >> To see this in action, try taking a moderately large smp system
> >> (8-way+) and scaling the number of flows.
> >>     
> >
> > I can maintain line-rate over 10GB with a 64-cpu box.
> Oh man, I am jealous of that 64-way :)
> 
> How many simultaneous flows?  What hardware?  What qdisc and other
> config do you use?  MTU?  I cannot replicate such results on 10GB even
> with much smaller cpu counts.

Sun Neptune NIU 10G with 24 TX queues.

And it's all because of the number of TX queues, nothing more.

It is essential for good performance with any level of cpu
arity.

