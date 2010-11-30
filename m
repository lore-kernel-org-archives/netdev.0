From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 19:19:50 +0000
Message-ID: <1291144790.21077.59.camel@bwh-desktop>
References: <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
	 <20101130.104834.112604433.davem@davemloft.net>
	 <1291144047.2904.224.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14835 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755959Ab0K3TTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:19:53 -0500
In-Reply-To: <1291144047.2904.224.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 20:07 +0100, Eric Dumazet wrote:
[...]
> Ben, could you remind us what was your ethtool interface ?
> 
> Something to setup a NUMA map for RX queues, TX queues ?
> 
> I can probably play with bnx2x and custom module param to test how it
> can help raw performance...

See these patches:

<http://patchwork.ozlabs.org/patch/65201/>
<http://patchwork.ozlabs.org/patch/65202/>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

