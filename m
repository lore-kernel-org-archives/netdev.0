From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] pktgen: Fix position of ip and udp header
Date: Tue, 04 Jun 2013 17:36:12 -0700 (PDT)
Message-ID: <20130604.173612.500926582139079555.davem@davemloft.net>
References: <08fe3153790311fbd98b1570a3e8134ddaac58a3.1370296008.git.tgraf@suug.ch>
	<51AD1294.8090604@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, horms@verge.net.au,
	dborkmann@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab3FEAgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:36:13 -0400
In-Reply-To: <51AD1294.8090604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 04 Jun 2013 00:03:00 +0200

> On 06/03/2013 11:49 PM, Thomas Graf wrote:
>> skb_set_network_header() expects an offset based on the data pointer
>> whereas skb_tail_offset() also includes the headroom. This resulted
>> in the ip header being written in a wrong location.
>>
>> Use return values of skb_put() directly and rely on skb->len to
>> set mac, network, and transport header.
>>
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Daniel Borkmann <dborkmann@redhat.com>
>> Assisted-by: Daniel Borkmann <dborkmann@redhat.com>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Thanks !
> 
> Acked-by: Daniel Borkmann <dborkmann@redhat.com>

Applied.
