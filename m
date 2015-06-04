From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net] openvswitch: disable LRO
Date: Wed, 03 Jun 2015 19:40:18 -0700 (PDT)
Message-ID: <20150603.194018.657019745002201264.davem@davemloft.net>
References: <5d7463bdfc32deb4c0b32ba7d9abf540fc6afed8.1433248445.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, fbl@sysclose.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbFDCkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:40:19 -0400
In-Reply-To: <5d7463bdfc32deb4c0b32ba7d9abf540fc6afed8.1433248445.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  2 Jun 2015 14:36:34 +0200

> Currently, openvswitch tries to disable LRO from the user space. This does
> not work correctly when the device added is a vlan interface, though.
> Instead of dealing with possibly complex stacked cross name space relations
> in the user space, do the same as bridging does and call dev_disable_lro in
> the kernel.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Flavio Leitner <fbl@redhat.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Resending, the patch seems to be completely missing in patchwork.

Sorry about that, patchwork lost 22 hours of netdev postings and I tried to
pick up the slack with my inbox, but... things happen :)

Applied, thanks Jiri.
