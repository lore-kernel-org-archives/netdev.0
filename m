From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable] [RFC] ipv6: don't flush routes when setting loopback down
Date: Sun, 23 Jan 2011 10:15:32 +0100
Message-ID: <20110123091531.GQ12837@1wt.eu>
References: <20110122.145438.193725532.davem@davemloft.net> <901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com> <20110122.214254.226765382.davem@davemloft.net> <20110123192416.73cd7521@s6510> <20110123192624.5cfe33d0@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbohac@suse.cz, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	stable@kernel.org, stephen.hemminger@vyatta.com,
	ebiederm@xmission.com, brian.haley@hp.com, lorenzo@google.com,
	David Miller <davem@davemloft.net>, maheshkelkar@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:58852 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab1AWJPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 04:15:53 -0500
Content-Disposition: inline
In-Reply-To: <20110123192624.5cfe33d0@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ first, is there a reason we have stable@ CCed on this thread ? ]

On Sun, Jan 23, 2011 at 07:26:24PM +1100, Stephen Hemminger wrote:
> > You are probably so upset because I stepped on code you worked hard
> > on. But the IPv6 semantics should not have been different from IPv4
> > and the disable_ipv6 flag was a poor API choice as well. Legacy
> > API's suck, I don't expect perfection but it should be possible
> > to make a working version that:
> > 
> > Allows disabling IPv6 completely on an interface
> > AND Has the same address and route semantics for both
> > IPv4 and IPv6.
> 
> Also for application sanity, Linux should behave the same as BSD

Stephen,

while I agree with all the points you made, David is right in that we
can't use a fix for a bug as a justification for breaking something
that worked for other people. It simply means that everything that was
merged since the first regression was introduced should be reverted
and reworked until a more satisfying solution is found.

Otherwise users lose trust and you have to deal with much more cases
when users report issues.

If the bug is caused by a deep design issue, then maybe a development
branch should be dedicated to it so that the persons affected by it
can track its evolution and report some feedback.

Regards,
Willy

