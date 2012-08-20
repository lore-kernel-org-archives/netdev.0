From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/18] netfilter: nf_nat: add protoff argument to packet
 mangling functions
Date: Mon, 20 Aug 2012 12:37:01 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208201236440.24912@stinky-local.trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <1345434006-16549-6-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208201000580.6101@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1208201000580.6101@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2012, Jan Engelhardt wrote:

>
> On Monday 2012-08-20 05:39, Patrick McHardy wrote:
>> index 0bb5a69..4b59a15 100644
>> --- a/include/linux/netfilter/nf_conntrack_amanda.h
>> +++ b/include/linux/netfilter/nf_conntrack_amanda.h
>> @@ -4,6 +4,7 @@
>>
>> extern unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
>> 					  enum ip_conntrack_info ctinfo,
>> +					  unsigned int protoff,
>> 					  unsigned int matchoff,
>> 					  unsigned int matchlen,
>> 					  struct nf_conntrack_expect *exp);
>
> What about using a structure to collect all the accumulating parameters,
> like we do for xtables match functions?

Yes, we could do that for the common parameters.
