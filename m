From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] ipv4: allow warming up the ARP cache with
 request type gratuitous ARP
Date: Tue, 19 Jan 2010 02:11:38 -0800 (PST)
Message-ID: <20100119.021138.172154379.davem@davemloft.net>
References: <201001190058.44495.opurdila@ixiacom.com>
	<20100119100913.65177497@opy.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, ja@ssi.bg, chavey@google.com,
	netdev@vger.kernel.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755489Ab0ASKL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:11:28 -0500
In-Reply-To: <20100119100913.65177497@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Tue, 19 Jan 2010 10:09:13 +1030

> I don't think this complies with the ARP RFC (RFC826). Walking through
> the validation steps, Gratuitous ARP seems to only pass if there is an
> existing entry in the table, otherwise they'd fail, as the target
> address in the GA packet doesn't match that of the receiving host.

It's fine if it's guarded by the per-device ARP_ACCEPT sysctl which
defaults to off, and that's what he's doing.
