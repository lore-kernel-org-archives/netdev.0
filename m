From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [RFC] ipv6: don't flush routes when setting loopback
 down
Date: Sun, 23 Jan 2011 11:57:19 -0800 (PST)
Message-ID: <20110123.115719.39193994.davem@davemloft.net>
References: <20110123091531.GQ12837@1wt.eu>
	<20110123213444.70d0b0f1@s6510>
	<m1k4hv5sue.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, w@1wt.eu, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, stable@kernel.org,
	stephen.hemminger@vyatta.com, brian.haley@hp.com,
	lorenzo@google.com, maheshkelkar@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50113
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752458Ab1AWT4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 14:56:44 -0500
In-Reply-To: <m1k4hv5sue.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 23 Jan 2011 11:21:29 -0800

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
>> I think this fixes the issue with disable_ipv6
> 
> Somehow I doubt deleting the ipv6 state, and removing the per device
> disable_ipv6 flag is going to be backwards compatible.
> 
> echo 0 > /proc/sys/net/ipv6/conf/disable_ipv6
> 
> Won't work.
> 
> What ever other good properties calling NETDEV_UNREGISTER for ipv6
> devices may have.

Don't worry Eric, I'm reverting all of the changes that caused this
problem in the first place.

If Stephen wants his change back in, he'll have to resubmit it in
a working state with all the known regressions dealt with.
