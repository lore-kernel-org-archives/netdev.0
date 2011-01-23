From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback down
Date: Sun, 23 Jan 2011 11:47:40 -0800 (PST)
Message-ID: <20110123.114740.189688941.davem@davemloft.net>
References: <901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
	<20110122.214254.226765382.davem@davemloft.net>
	<20110123192416.73cd7521@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, ebiederm@xmission.com,
	jbohac@suse.cz, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752372Ab1AWTrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 14:47:07 -0500
In-Reply-To: <20110123192416.73cd7521@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 23 Jan 2011 19:24:16 +1100

> You are probably so upset because I stepped on code you worked hard
> on.

Frankly, I honestly don't care much at all about ipv6, it's still only
a tiny minuscule fraction of actual usage in this world, even with
ipv4 addresses basically completely depleted right now, and it's also
an over-engineered monster.

> But the IPv6 semantics should not have been different from IPv4
> and the disable_ipv6 flag was a poor API choice as well.

There are no equivalent semantics, because nobody wants to disable
all IPV4 activity and socket protocol operations.  People want it
only for ipv6.

This interface was choosen because this is what users asked for.

They wanted global and per-interface ways to disable IPV6 protocol
activity, so that's what we gave them.

Stephen you don't get it.  The ball is completely in your court
about this, you broke stuff to fix stuff and that's not allowed.

You have also been given months of time to undo the breakage.
Normally I would just immediately revert, so you were given
special allowances because I respect and trust you.

So stop this BS where you say that I'm treating you in an
unfair way.
