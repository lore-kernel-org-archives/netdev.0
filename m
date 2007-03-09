From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: about : [NET]: Replace CONFIG_NET_DEBUG with sysctl.
Date: Fri, 09 Mar 2007 08:22:54 -0800
Message-ID: <45F189DE.7030206@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>	<20070308205305.582324346@linux-foundation.org> <20070308.204209.69409441.davem@davemloft.net> <45F0FFE7.1080304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38661 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767352AbXCIQXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:23:11 -0500
In-Reply-To: <45F0FFE7.1080304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Hello David and Stephen
>
> I see git commit 8e2101a9faab43dcf307d46784a1ede7997fe729
> and its potential problems :
>
> Here on my x86_64 machine :
>
> ffffffff806e7520 d rtnl_mutex
> ffffffff806e7538 D net_msg_cost
> ffffffff806e753c D net_msg_burst
> ffffffff806e7540 D net_msg_warn
> ffffffff806e7560 d lweventlist_lock
>
It probably is worth making a hot/cold map somehow. Ideally some 
automated version
of something like oprofile uses (memprofile?)
> So net_msg_{cost|burst|warn} are on two 'heavy' cachelines.
>
> I gently ask that any new sysctl is '__read_mostly' tagged.
Why not all the old one's as well?
