From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/5] Refactor IP defragmentation and
 fragmenation APIs for OVS conntrack support
Date: Wed, 11 Mar 2015 16:45:50 -0400 (EDT)
Message-ID: <20150311.164550.2247000676434784013.davem@davemloft.net>
References: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbCKUpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:45:52 -0400
In-Reply-To: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Tue, 10 Mar 2015 12:07:13 -0700

> These are the patches refactors the core APIs for both IPv4 and IPv6.
> 
> The intended use for openvswitch has been posted in the eariler RFC:
> 
> http://lists.openwall.net/netdev/2015/03/02/220

Yet another hack for openvswitch.

I'm tired of this frankenstein subsystem deciding what the invariants
actually are for our core APIs.

It is completely natural to expect that there is some device to
interrogate regarding link layer capabilities, such as MTU.

And it is openvswitch's problem that they decided to break this
invariant.

I'm not accepting hacks in ipv4/ipv6 to workaround a mistake that
the OVS folks decided to make, sorry.

Stop making OVS such a damn mess, please.
