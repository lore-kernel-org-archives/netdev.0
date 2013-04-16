From: Tomas Agartz <tlund@nxs.se>
Subject: Re: No longer able to add iptunnel interface to bridge?
Date: Wed, 17 Apr 2013 01:22:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.1304170119280.20041@envy.nxs.se>
References: <Pine.LNX.4.61.1304151757340.20041@envy.nxs.se>
 <20130415111213.62c4d117@samsung-9>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from envy.nxs.se ([212.247.200.182]:53323 "EHLO envy.nxs.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965610Ab3DPXWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 19:22:17 -0400
In-Reply-To: <20130415111213.62c4d117@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Apr 2013, Stephen Hemminger wrote:

> On Mon, 15 Apr 2013 18:14:32 +0200 (CEST)
> Tomas Agartz <tlund@nxs.se> wrote:
>
>> After rebooting my router/firewall (Debian Wheezy with debian 3.2.41-2 
>> kernel), I am no longer able to add an iptunnel to a bridge interface.
>
>
> You created a network level (L3) tunnel, which starts with IP header. 
> Bridging requires an Ethernet like (L2) tunnel, where packets start with 
> Ethernet header.

Yeah, looking further into this, i figured out a different (unrelated) 
problem that was the real root cause. The fact that the tunnel was never 
added to the bridge (and it has never been) was not related.

Sorry for bothering you guys :)
