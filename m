From: David Miller <davem@davemloft.net>
Subject: Re: Missing device binding relating to tcp_v4_send_reset?
Date: Tue, 10 Aug 2010 01:48:46 -0700 (PDT)
Message-ID: <20100810.014846.258126767.davem@davemloft.net>
References: <4C603EF2.9010902@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50078
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab0HJIs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:48:26 -0400
In-Reply-To: <4C603EF2.9010902@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 09 Aug 2010 10:46:26 -0700

> This snippet is from some patches Patrick did for me some time
> back.  I think the rest of his work has been merged upstream, but
> this patch was not.  I'm honestly not sure if it's needed or not,
> but we've been running with it for at least a year or so and it's
> been working fine for us.

There is no reason at all to force a reply to a packet to
go out of the same interface as the packet which triggered
that reply arrived upon.
