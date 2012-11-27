From: Shan Wei <shanwei88@gmail.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Tue, 27 Nov 2012 12:56:19 +0800
Message-ID: <50B447F3.2090806@gmail.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47729 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757956Ab2K0E42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 23:56:28 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so8583471pbc.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 20:56:28 -0800 (PST)
In-Reply-To: <50B43F12.1090709@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang said, at 2012/11/27 12:18:
>>
>>>
>>>  for the format of information which seq_printf output:
>>>    it is not belong to OS API level for outside (at least, for current case, it is true). 
>>>    so we need not keep 'compatible' of it, so %16s is not necessary.
>>
>> Can you explain If we don't change to %s, what will happen?
>>
> 
>   for outside, nothing will happen.
> 
>   so it is not for correctness, it is only for "keep source code simple and clear".

So, it's a clean-up type patch which is just for developer,
but with the change of /proc interface which is for user.
user is first, so let us end this thread unless you have necessary reasons to do it. 

Thanks  
Shan Wei
