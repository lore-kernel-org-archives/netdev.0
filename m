From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next 1/2] net: reset mac header in dev_start_xmit()
Date: Tue, 05 Feb 2013 22:40:44 -0800
Message-ID: <5111FAEC.2020203@candelatech.com>
References: <1360131740.28557.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52981 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab3BFGks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 01:40:48 -0500
In-Reply-To: <1360131740.28557.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2013 10:22 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On 64 bit arches :
>
> There is a off-by-one error in qdisc_pkt_len_init() because
> mac_header is not set in xmit path.
>
> skb_mac_header() returns an out of bound value that was
> harmless because hdr_len is an 'unsigned int'
>
> On 32bit arches, the error is abysmal.
>
> This patch is also a prereq for "macvlan: add multicast filter"

I'll go ahead and apply this one to our tree for testing, and will
apply the multicast one as soon as I resolve some bugs that currently
have me swamped...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
