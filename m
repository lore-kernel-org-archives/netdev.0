From: "Park Ji-In" <tisphie@gmail.com>
Subject: Re: [PATCH] rearrange structure xfrm_userpolicy_type in linux/xfrm.h
Date: Thu, 14 Aug 2008 14:47:24 +0900
Message-ID: <c4ee36230808132247o73a6e186i6cfb50a1731cfe03@mail.gmail.com>
References: <c4ee36230808130056s7d01ebaeh677593ef7c099985@mail.gmail.com>
	 <20080813.013949.193697827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:47288 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbYHNFr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 01:47:26 -0400
Received: by gxk9 with SMTP id 9so1968214gxk.13
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 22:47:25 -0700 (PDT)
In-Reply-To: <20080813.013949.193697827.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/8/13 David Miller <davem@davemloft.net>:
> From: "Park Ji-In" <tisphie@gmail.com>
> Date: Wed, 13 Aug 2008 16:56:32 +0900
>
>> struct xfrm_userpolicy_type in linux/xfrm.h is something strange,
>> It seems that to align 4byte, but it's size in x86 with gcc is 6byte.
>> rearrange to fit in 4byte structure
>>
>> Signed-off-by: Park Jiin <tisphie@gmail.com>
>
> You can't change this structure as it's exported to userspace and
> therefore part of many already compiled userland binaries out there.
>

Oh. that's the problem what I missed.
