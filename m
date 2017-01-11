From: Ian Kumlien <ian.kumlien@gmail.com>
Subject: Re: 4.9.2 panic, __skb_flow_dissect, gro?
Date: Wed, 11 Jan 2017 16:19:41 +0100
Message-ID: <CAA85sZvW_SEfqGtrUT7UXtNWj6jz=NkLrSHdYMP5rspoYbbEOA@mail.gmail.com>
References: <359da98eb44a5a9f9f286cc380143654@nuclearcat.com>
 <96694297c5f7178b92bfd9a12bef4a42@nuclearcat.com> <20170110.200804.303728442314129894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36077 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdAKPUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 10:20:02 -0500
Received: by mail-oi0-f50.google.com with SMTP id u143so181312838oif.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 07:20:02 -0800 (PST)
In-Reply-To: <20170110.200804.303728442314129894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 2:08 AM, David Miller <davem@davemloft.net> wrote:
> From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> Date: Wed, 11 Jan 2017 01:49:34 +0200
>
>> It seems this patch solve issue. I hope it will go to stable asap,
>> because without it loaded routers crashing almost instantly on 4.9.
>
> I will submit this soon.

Btw, any special reason why that code is written like it is? Stack depth?
