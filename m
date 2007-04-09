From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 11:44:02 -0700 (PDT)
Message-ID: <20070409.114402.45491411.davem@davemloft.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	<1176136628.8459.34.camel@johannes.berg>
	<461A70A5.8060607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, ebiederm@xmission.com,
	shemminger@linux-foundation.org, jgarzik@pobox.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, greearb@candelatech.com, dlezcano@fr.ibm.com,
	dim@openvz.org, containers@lists.osdl.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40199
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753412AbXDISoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 14:44:02 -0400
In-Reply-To: <461A70A5.8060607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 09 Apr 2007 18:58:13 +0200

> It would be nice if someone would finally come up with a generic
> interface based on netlink (RTM_NEWLINK) instead of adding yet
> another couple of homegrown interfaces.

I absolutely agree, using these ioctls and sysfs/procfs crap
is totally insane given that we have a core mechanism for
network configuration.
