From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH net-next 1/1] netns: IPv6 address labels per namespace.
Date: Wed, 28 May 2008 14:14:26 +0200
Message-ID: <483D4CA2.80409@bull.net>
References: <20080527144050.754524679@theryb.frec.bull.fr> <20080528.210514.118764806.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:45105 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYE1MPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 08:15:32 -0400
In-Reply-To: <20080528.210514.118764806.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / ???? wrote:
> In article <20080527144050.754524679@theryb.frec.bull.fr> (at Tue, 27 May 2008 16:40:42 +0200), Benjamin Thery <benjamin.thery@bull.net> says:
> 
>> This patch makes IPv6 address labels per network namespace.
>> It keeps the global label tables, ip6addrlbl_table, but 
>> adds a 'net' member to each ip6addrlbl_entry.
>> This new member is taken into account when matching labels.
> 
> Could you please eliminate penalty without namespece
> like dev_net() etc.?

Yes, sure.
In fact, I already have got a patch ready which ifdef's the 'net'
member and use xxx_net() functions. But it introduces a few #ifdef
CONFIG_NET_NS in net/ipv6/addrlabel.c and I wasn't sure which one was
the best for inclusion.

I'll send a v2 this afternoon.

--benjamin

> 
> --yoshfuji
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
