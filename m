From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bonding: use the correct ether type for
 alb
Date: Fri, 14 Mar 2014 15:12:33 -0400 (EDT)
Message-ID: <20140314.151233.2074289397216762525.davem@davemloft.net>
References: <1394710918-29540-3-git-send-email-vfalico@redhat.com>
	<20140314.142935.1237930025090619830.davem@davemloft.net>
	<20140314184251.GA30498@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557AbaCNTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:12:35 -0400
In-Reply-To: <20140314184251.GA30498@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Fri, 14 Mar 2014 19:42:52 +0100

> On Fri, Mar 14, 2014 at 02:29:35PM -0400, David Miller wrote:
>>From: Veaceslav Falico <vfalico@redhat.com>
>>Date: Thu, 13 Mar 2014 12:41:58 +0100
>>
>>> @@ -1005,7 +1005,7 @@ static void alb_send_lp_vid(struct slave *slave,
>>> u8 mac_addr[],
>>>  	memset(&pkt, 0, size);
>>>  	ether_addr_copy(pkt.mac_dst, mac_addr);
>>>  	ether_addr_copy(pkt.mac_src, mac_addr);
>>> -	pkt.type = cpu_to_be16(ETH_P_LOOP);
>>> +	pkt.type = cpu_to_be16(ETH_P_LOOPBACK);
>>
>>Had this really never worked properly at all?
> 
> Yep, but only in cases where the hw/sw didn't filter out broken
> packets
> *before* arp processing, as far as I can tell.

Hmmm... what I meant was, was anyone able to receive these packets?
I think the answer is no.
