From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reallocate new socket option number for
 IPV6_AUTOFLOWLABEL
Date: Wed, 06 Aug 2014 15:17:15 -0700 (PDT)
Message-ID: <20140806.151715.2113268376810129182.davem@davemloft.net>
References: <1407363050-3573-1-git-send-email-pablo@netfilter.org>
	<20140806221313.GA4426@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, therbert@google.com,
	netfilter-devel@vger.kernel.org, davej@redhat.com,
	netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140806221313.GA4426@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Thu, 7 Aug 2014 00:13:13 +0200

> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> cb1ce2e ("ipv6: Implement automatic flow label generation on transmit")
>> accidentally uses socket option 64, which is already used by ip6tables:
>> 
>>  IP6T_SO_SET_REPLACE / IP6T_SO_GET_INFO               64
>>  IP6T_SO_SET_ADD_COUNTERS / IP6T_SO_GET_ENTRIES       65
>> 
>> There is comment include/uapi/linux/in6.h warning about that.
>> 
>> Cc: Tom Herbert <therbert@google.com>
>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
...
>> @@ -250,6 +249,7 @@ struct in6_flowlabel_req {
>>   */
>>  #define IPV6_RECVTCLASS		66
>>  #define IPV6_TCLASS		67
>> +#define IPV6_AUTOFLOWLABEL	68
> 
> This clashes with IP6T_SO_GET_REVISION_MATCH 8-}

:-)  77 appears to be the next actually usable value.
