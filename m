From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 16:23:06 -0400 (EDT)
Message-ID: <20110518.162306.441229167098643303.davem@davemloft.net>
References: <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
	<20110518.155200.801089483916944725.davem@davemloft.net>
	<20110518202025.GC4175@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tsunanet@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab1ERU0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 16:26:52 -0400
In-Reply-To: <20110518202025.GC4175@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 18 May 2011 22:20:25 +0200

> I like the idea to make the initial RTO a knob because we in a
> isolated MANET environment have a RTT larger then 1 second.

Then this gets back to the fact that this is a network
attribute and thus more suitable as a route metric not
a global system-wide sysctl.
