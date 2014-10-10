From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 12:41:45 -0400 (EDT)
Message-ID: <20141010.124145.1972528960826419387.davem@davemloft.net>
References: <5437F072.5060502@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>
	<1412955219.9362.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, alexander.h.duyck@redhat.com,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbaJJQlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 12:41:51 -0400
In-Reply-To: <1412955219.9362.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Oct 2014 08:33:39 -0700

> On Fri, 2014-10-10 at 14:57 +0000, David Laight wrote:
> 
>> I think there is code to copy the IP and TCP headers to aligned memory
>> before they are parsed.
> 
> There is no such thing. You are here on netdev list, please read the
> code before doing such claims.

+1
