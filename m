From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Fri, 16 Nov 2007 12:17:48 +0800
Message-ID: <473D19EC.6030903@cn.fujitsu.com>
References: <E1IssYb-0000KG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:60096 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756439AbXKPEUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 23:20:06 -0500
In-Reply-To: <E1IssYb-0000KG-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu said the following on 2007-11-16 12:11:
> Wang Chen <wangchen@cn.fujitsu.com> wrote:
>> So, I think the checksum in udp_queue_rcv_skb() actually does
>> the work, not that in udp_recvmsg() and udp_poll().
>>
>> If I am wrong, please point out.
> 
> We may have a bug in the accounting area.  Check the recent
> patch made to UDP/IPv6 which is probably needed here as well.
> 

Like dave said, decrementing the InDataGrams in this case is an
option.
I will check the same place of UDP/IPv6.

> Hmm, we really need to spend more time on merging stuff between
> IPv4 and IPv6 to save all this duplication of effort.
> 

Definitely necessary.

