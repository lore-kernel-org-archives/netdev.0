From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2 nf-next 3/6] netfilter: bridge: use skb->cb to track
 otherhost mangling
Date: Thu, 12 Mar 2015 19:40:09 +0100
Message-ID: <5501DD89.4070408@hartkopp.net>
References: <1426179925-18220-1-git-send-email-fw@strlen.de> <1426179925-18220-4-git-send-email-fw@strlen.de> <5501D498.4050003@hartkopp.net> <20150312183113.GA12169@breakpoint.cc> <20150312183503.GB12169@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eyal Birger <eyal.birger@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:13775 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbbCLSkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:40:13 -0400
In-Reply-To: <20150312183503.GB12169@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2015 07:35 PM, Florian Westphal wrote:
> Florian Westphal <fw@strlen.de> wrote:
>>>> +	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
>>>> +
>>>
>>> Please use sock_skb_cb_check_size(size) for cb size checking which is the
>>> 'new' check for cb sizes for netdev.
>>
>> I can do this for conistency, but its technically not needed here.
> 
> I take that back, it would actually be inconsistent to use
> sock_skb_cb_check_size since nf_bridge skbs will not be associated with
> sockets.
> 

Ok. I just wanted to make sure that the use of the cb[]-space doesn't clash
with the new space that's acquired by the dropcount stuff.

Sorry for the noise :-)

Best regards,
Oliver
