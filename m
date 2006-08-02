From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: (usagi-core 30280) Re: [PATCH 10/23] [PATCH] [XFRM]: Trace which
 secpath state is reject factor.
Date: Wed, 02 Aug 2006 15:07:46 +0900
Message-ID: <44D04132.3050505@linux-ipv6.org>
References: <11541654291610-git-send-email-nakam@linux-ipv6.org> <20060801.171501.95894508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:13970 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750836AbWHBGHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 02:07:52 -0400
To: usagi-core@linux-ipv6.org
In-Reply-To: <20060801.171501.95894508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Sat, 29 Jul 2006 18:30:29 +0900
> 
>> @@ -272,6 +272,9 @@ #define XFRM_TYPE_NON_FRAGMENT	1
>>  	void			(*destructor)(struct xfrm_state *);
>>  	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
>>  	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
>> +#ifdef CONFIG_XFRM_ADVANCED
>> +	int			(*reject)(struct xfrm_state *, struct sk_buff *skb, struct flowi *);
>> +#endif
> 
> xfrm_secpath_reject() unconditionally dereferences this new reject
> operation pointer, but this patch contains no assignments of it.
> 
> Please send incremental patches that are fully functional all by
> themselves, so that if each one is applied, it would compile and
> work.

Thanks, I'll send so next time.

-- 
Masahide NAKAMURA
