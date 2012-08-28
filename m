From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] cxgb3: remove pointless conditional before kfree_skb()
Date: Tue, 28 Aug 2012 22:19:57 +0800
Message-ID: <CAPgLHd8RKXR-TSnbJLQ2GR28ORB7HTe4kDk8wkwo_e-r+0ue4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: divy@chelsio.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43344 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759Ab2H1OT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Aug 2012 10:19:58 -0400
Received: by qaas11 with SMTP id s11so2685729qaa.19
        for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 07:19:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2012 09:24 PM, David Laight wrote:
>> -	if (t->nofail_skb)
>> -		kfree_skb(t->nofail_skb);
>> +	kfree_skb(t->nofail_skb);
> Some of these conditionals might be there for performance
> reasons - eg if common path and normally NULL.

I have a quick look at those code, cxgb3_offload_deactivate()
is only used when remove device or device error and then disable
the device, so maybe it is not a common path.
