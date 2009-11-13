From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 04/10] AOE: use rcu to find network device
Date: Fri, 13 Nov 2009 14:24:07 -0800
Message-ID: <20091113142407.2fab4d7b@s6510>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.409162953@vyatta.com>
	<8ffe0a1df67d13a45a413f40d00dd80a@coraid.com>
	<20091110150617.0e6920f0@nehalam>
	<a30adfc1658e1d5f2f35fee1bb89b364@coraid.com>
	<11632bada28093377596d63180fe6c1c@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ecashin@coraid.com, davem@davemloft.net, harvey.harrison@gmail.com,
	bzolnier@gmail.com, netdev@vger.kernel.org
To: Ed Cashin <ecashin@coraid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54560 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755448AbZKMWYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 17:24:23 -0500
In-Reply-To: <11632bada28093377596d63180fe6c1c@coraid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 16:39:49 -0500
Ed Cashin <ecashin@coraid.com> wrote:

> I will be testing the patch below on Monday.  It is based on Stephen
> Hemminger's starter patch (Thanks!).  It adds handling for the case
> where all of the local network interfaces have become unusable.  In
> that case, sent packets and retransmitted packets are effectively
> dropped, and the driver's handling of ethernet's unreliability takes
> care of things as usual.  If a local interface becomes usable in time
> no I/O will fail.
> 
> After testing I'll make a proper changelog entry.  In brief this patch
> allows the aoe driver to correctly take references on the net_device's
> that it uses, handle their removal via a callback, and handle their
> complete absence, too.

Looks good, good luck with testing.
