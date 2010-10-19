From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: unix: make some variables constant
Date: Tue, 19 Oct 2010 14:03:31 +0800
Message-ID: <AANLkTi=e6ZCGNN2ZTYZ3RZ2_XtX=W74-RSNYOo7+gRk4@mail.gmail.com>
References: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com> <1287467263.2775.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41577 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab0JSGDy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 02:03:54 -0400
Received: by wwj40 with SMTP id 40so748276wwj.1
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 23:03:53 -0700 (PDT)
In-Reply-To: <1287467263.2775.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 1:47 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 19 octobre 2010 =E0 13:24 +0800, Changli Gao a =E9crit :
>> And since ctl_table.data is initialized later, we don't need to init=
ialize
>> the data member of the template variable unix_table.
>>
>
> The init cost is nothing, since its a data blob that must be there
> anyway.

Yes. I have tried to avoid global variable unix_table and unix_path,
then I got a bigger kernel image, so I gave it up.

>
> We could even avoid the kmemdup() if CONFIG_NET_NS is not set
>
>

It is a good idea. We can check if the NS is init_net before kmalloc an=
d kfree.

I'll send a update patch later. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
