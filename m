From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sun, 23 Jan 2011 19:24:16 +1100
Message-ID: <20110123192416.73cd7521@s6510>
References: <20110122.145438.193725532.davem@davemloft.net>
	<901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
	<20110122.214254.226765382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, ebiederm@xmission.com,
	jbohac@suse.cz, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36639 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab1AWIYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jan 2011 03:24:25 -0500
In-Reply-To: <20110122.214254.226765382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Jan 2011 21:42:54 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen.hemminger@vyatta.com>
> Date: Sat, 22 Jan 2011 20:41:12 -0800 (PST)
> 
> > Having IPv6 remove all addresses when link goes down is fundamentally broken
> > that is what the original problem being fixed. For users on servers or using
> > Quagga this matters, how do you plan to fix that?
> 
> How about in a way that doesn't break stuff?
> 
> And it's been beyond proven that people give more of a crap
> about disable_ipv6 than the thing you keep claiming is a big deal.
> 
> NOBODY other than you even noticed the issue or made a report about
> it.
> 
> Yet we have people actively complaining about disable_ipv6 being
> broken.
> 
> So you lose on two counts.  You can't fix things by breaking other
> stuff, and your obscure stuff matters less than things people
> actually notice being broken.

You are probably so upset because I stepped on code you worked hard
on. But the IPv6 semantics should not have been different from IPv4
and the disable_ipv6 flag was a poor API choice as well. Legacy
API's suck, I don't expect perfection but it should be possible
to make a working version that:

Allows disabling IPv6 completely on an interface
AND Has the same address and route semantics for both
IPv4 and IPv6.


