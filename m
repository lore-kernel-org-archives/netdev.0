From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6 addresses.
Date: Wed, 11 Jun 2008 20:08:38 +0200
Message-ID: <f4845fc0806111108q27a3d4f5o84ac638e58fb6ff0@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <1213204329-10973-3-git-send-email-juliusv@google.com>
	 <4850076B.302@trash.net>
	 <f4845fc0806111041u2a9a197fseefe300ffbbda3c3@mail.gmail.com>
	 <485010E9.6000506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:24013 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbYFKSIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 14:08:44 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m5BI8dLD031359
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 19:08:40 +0100
Received: from py-out-1112.google.com (pyhn24.prod.google.com [10.34.240.24])
	by zps36.corp.google.com with ESMTP id m5BI8cbd009395
	for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 11:08:38 -0700
Received: by py-out-1112.google.com with SMTP id n24so1218000pyh.20
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 11:08:38 -0700 (PDT)
In-Reply-To: <485010E9.6000506@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 11, 2008 at 7:52 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>
>> On Wed, Jun 11, 2008 at 7:12 PM, Patrick McHardy <kaber@trash.net> wrote:
>>
>>>
>>> include/net is always kernel only. At least it should be that way.
>>>
>>
>> ipvsadm has:
>>
>> INCLUDE         = -I/usr/src/linux/include -I.. -I.
>>
>> in its Makefile and then includes net/ip_vs.h. Even in the current version
>> :(
>>
>
> OK, thanks for the explanation.
>
>>>>  #define IP_VS_IFNAME_MAXLEN    16
>>>>  +union ip_vs_addr_user {
>>>> +       __be32                  v4;
>>>> +       struct in6_addr         v6;
>>>> +};
>>>>
>>>>
>>>
>>> Can't you use nf_inet_addr for this?
>>>
>>
>> Ah, yes. I either didn't know about this or wasn't sure if it was
>> appropriate to reuse that struct from netfilter. I will look into
>> putting this in!
>>
>>
>
> Thanks. But please remember to keep netdev CCed on responses
> to review.

Yes, sorry! Re-added the lists for this response.

Julius

-- 
Google Switzerland GmbH
