From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Why is LRO off by default on ixgbe?
Date: Wed, 23 Sep 2009 09:53:56 -0700
Message-ID: <20090923095356.7f9aef37@s6510>
References: <4ABA4D07.50107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43290 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbZIWQyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 12:54:00 -0400
In-Reply-To: <4ABA4D07.50107@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009 09:29:59 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I just noticed that enabling LRO on ixgbe lets me reach about 9Gbps receive on two
> NICs concurrently in an NFS test, where I was only getting about 6Gbps w/out it (1500 MTU).
> 
> Why is LRO disabled by default?
> 
> Thanks,
> Ben

LRO is turned off if bridging or routing because of End to End requirements.
