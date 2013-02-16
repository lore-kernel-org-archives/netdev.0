From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next (V2)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Sat, 16 Feb 2013 08:15:13 -0800
Message-ID: <1361031313.19353.63.camel@edumazet-glaptop>
References: <511F1E03.9010205@linux-ipv6.org>
	 <1360995918.19353.56.camel@edumazet-glaptop>
	 <511F6FF1.9000004@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ben Greear <greearb@candelatech.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43131 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab3BPQPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 11:15:22 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so2186174pad.7
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 08:15:21 -0800 (PST)
In-Reply-To: <511F6FF1.9000004@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 20:39 +0900, YOSHIFUJI Hideaki wrote:

> Could you elaborate, please?
> 
> The patch does not compare incoming interface if address is
> non-link-local unicast address.

There must be a reason ipv6 reasm is duplicated in
net/ipv6/netfilter/nf_conntrack_reasm.c

netfilter uses the notion of ct zone, and several nics can belong to
same zone.

Anyway your patch touches netfilter land, so must be CC to netfilter
guys.

M:      Pablo Neira Ayuso <pablo@netfilter.org>
M:      Patrick McHardy <kaber@trash.net>
L:      netfilter-devel@vger.kernel.org
