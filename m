From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: Don't lookup dst if transport dst is
 still valid
Date: Fri, 02 Aug 2013 12:36:54 -0700 (PDT)
Message-ID: <20130802.123654.1065502694669483211.davem@davemloft.net>
References: <1375411513-12551-1-git-send-email-fan.du@windriver.com>
	<51FBC8CA.8030005@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab3HBTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 15:36:55 -0400
In-Reply-To: <51FBC8CA.8030005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 02 Aug 2013 10:57:14 -0400

> On 08/01/2013 10:45 PM, Fan Du wrote:
>> When sctp sits on IPv6, sctp_transport_dst_check pass cookie as ZERO,
>> as a result ip6_dst_check always fail out. This behaviour makes
>> transport->dst useless, because every sctp_packet_transmit must look
>> for valid dst.
>>
>> Add a dst_cookie into sctp_transport, and set the cookie whenever we
>> get new dst for sctp_transport. So dst validness could be checked
>> against it.
>>
>> Since I have split genid for IPv4 and IPv6, also delete/add IPv6
>> address
>> will also bump IPv6 genid. So issues we discussed in:
>> http://marc.info/?l=linux-netdev&m=137404469219410&w=4
>> have all been sloved for this patch.
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied.
