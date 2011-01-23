From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sat, 22 Jan 2011 20:41:12 -0800 (PST)
Message-ID: <901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
References: <20110122.145438.193725532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, jbohac@suse.cz,
	brian haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52372 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab1AWElQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 23:41:16 -0500
In-Reply-To: <20110122.145438.193725532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having IPv6 remove all addresses when link goes down is fundamentally broken
that is what the original problem being fixed. For users on servers or using
Quagga this matters, how do you plan to fix that?

----- Original Message -----
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sun, 23 Jan 2011 09:39:40 +1100
> 
> > The design problem behind all this is that sysctl disable_ipv6 as
> > currently implemented is passive (just changes a variable). It needs
> > to be implemented
> > as a more active step that does the same thing as removing the
> > interface from
> > ipv6. I will look into it after LCA.
> 
> All of this stuff worked before your change Stephen.
> 
> It doesn't matter how it was implemented before, IT WORKED.
> 
> You broke it, and it's still broken.
> 
> You keep talking about fixing things other than the changes
> you made, but honestly I think we're at the point where you've
> been given enough changes and we need to simply revert your
> change.
> 
> Things like that can't run on and on for months, I don't care
> what the reason is.
