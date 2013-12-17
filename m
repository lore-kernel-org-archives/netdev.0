From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 9/10] lro: remove unused code
Date: Tue, 17 Dec 2013 17:20:35 -0500 (EST)
Message-ID: <20131217.172035.1066510228420498241.davem@davemloft.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
	<20131216104531.27407d6f@nehalam.linuxnetplumber.net>
	<1387223667.1799.32.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab3LQWUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:20:36 -0500
In-Reply-To: <1387223667.1799.32.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 16 Dec 2013 19:54:27 +0000

> On Mon, 2013-12-16 at 10:45 -0800, Stephen Hemminger wrote:
>> This code is not used anywhere in net-next
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> [...]
>> --- a/net/ipv4/inet_lro.c	2013-10-06 14:48:24.966449847 -0700
>> +++ b/net/ipv4/inet_lro.c	2013-12-12 13:28:43.435225437 -0800
>> @@ -506,23 +506,6 @@ void lro_receive_skb(struct net_lro_mgr
>>  }
>>  EXPORT_SYMBOL(lro_receive_skb);
>>  
>> -void lro_receive_frags(struct net_lro_mgr *lro_mgr,
>> -		       struct skb_frag_struct *frags,
>> -		       int len, int true_size, void *priv, __wsum sum)
>> -{
>> -	struct sk_buff *skb;
>> -
>> -	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);
> 
> You should remove unused functions recursively.  After this, you can
> remove at least __lro_proc_segment(), lro_gen_skb() and lro_add_frags().

Agreed.
