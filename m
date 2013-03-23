From: tingwei liu <tingw.liu@gmail.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Sat, 23 Mar 2013 09:24:30 +0800
Message-ID: <CA+qZnST22XrkFgsNqE8aAziD++4EZXzBGzM-4GNbbxfi8z+yvQ@mail.gmail.com>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
	<1363793549.3333.12.camel@edumazet-glaptop>
	<1363799443.2677.2.camel@bwh-desktop.uk.solarflarecom.com>
	<1363801389.3333.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:41976 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422733Ab3CWBYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 21:24:31 -0400
Received: by mail-ie0-f171.google.com with SMTP id e14so3795354iej.30
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 18:24:30 -0700 (PDT)
In-Reply-To: <1363801389.3333.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 1:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-03-20 at 17:10 +0000, Ben Hutchings wrote:
>
>> If they are wrongly documented as 'can be called from any context', yes.
>
> Wow, thats really useful.
>
> Why is this function not allowed from hard irq context, we have no idea.
When function "list_netdevice" get write lock "dev_base_lock" only
disable soft interrupt. So dev_get_by_name get read lock
"dev_base_lock", can not called on interrupt context.
>
> Why someone would like to call it from hard irq context, we have no
> idea.
>
> I hope to get a clear explanation here, not only playing with words.
>
> Thanks
>
>
