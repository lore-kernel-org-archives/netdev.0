From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/6] ipv6: netfilter: remove unnecessary braces
Date: Sat, 25 Apr 2015 19:54:10 +0300
Message-ID: <553BC6B2.5080807@cogentembedded.com>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>	 <1429954020-11763-4-git-send-email-ipm@chirality.org.uk> <1429977542.32250.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:32864 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbDYQyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 12:54:14 -0400
Received: by lbbzk7 with SMTP id zk7so56382250lbb.0
        for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 09:54:13 -0700 (PDT)
In-Reply-To: <1429977542.32250.12.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/25/2015 06:59 PM, Joe Perches wrote:

>> Remove braces from a few if statements where not required.

> trivia:

>> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
> []
>> @@ -151,9 +151,8 @@ ip6_packet_match(const struct sk_buff *skb,
>>   				ip6info->proto);
>>
>>   		if (ip6info->proto == protohdr) {
>> -			if (ip6info->invflags & IP6T_INV_PROTO) {
>> +			if (ip6info->invflags & IP6T_INV_PROTO)
>>   				return false;
>> -			}
>>   			return true;

> maybe
> 			return (!(ip6info->invflags & IP6T_INV_PROTO));

    Parens around the *return* expression are not necessary. :-)

WBR, Sergei
