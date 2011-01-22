From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sat, 22 Jan 2011 14:54:38 -0800 (PST)
Message-ID: <20110122.145438.193725532.davem@davemloft.net>
References: <20110119120123.40974cbe@s6510>
	<m1k4hxuzcq.fsf@fess.ebiederm.org>
	<20110123093940.4f6075a3@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jbohac@suse.cz, brian.haley@hp.com,
	netdev@vger.kernel.org, maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751563Ab1AVWyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jan 2011 17:54:05 -0500
In-Reply-To: <20110123093940.4f6075a3@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 23 Jan 2011 09:39:40 +1100

> The design problem behind all this is that sysctl disable_ipv6 as currently
> implemented is passive (just changes a variable). It needs to be implemented
> as a more active step that does the same thing as removing the interface from
> ipv6.  I will look into it after LCA. 

All of this stuff worked before your change Stephen.

It doesn't matter how it was implemented before, IT WORKED.

You broke it, and it's still broken.

You keep talking about fixing things other than the changes
you made, but honestly I think we're at the point where you've
been given enough changes and we need to simply revert your
change.

Things like that can't run on and on for months, I don't care
what the reason is.

