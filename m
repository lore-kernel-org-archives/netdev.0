From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/xfrm: stack out-of-bounds in xfrm_flowi_sport
Date: Tue, 28 Feb 2017 14:39:17 +0100
Message-ID: <CACT4Y+Y7xvGvAGVM_V2e+6+Tmmc-ZKdyUz3x-n6KvevW98iJnQ@mail.gmail.com>
References: <CACT4Y+ZBY+gYUJ9NuxPByEbbrR7M09vBd5Lx4=xGSGXSxai==Q@mail.gmail.com>
 <20170214070854.GH30338@gauss.secunet.com> <CACT4Y+aPd8drh7MQf8cXLs_9f-oymf6YiWfN+owUsSYYz0yMzA@mail.gmail.com>
 <20170214090816.GJ30338@gauss.secunet.com> <CACT4Y+a7-TXY2f14Cn0wUapiJ5BYv=2wkJ4vcMGMnbDjqTPnVw@mail.gmail.com>
 <20170215062622.GO30338@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:36116 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdB1Nr5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 08:47:57 -0500
Received: by mail-ua0-f179.google.com with SMTP id 72so13434730uaf.3
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 05:47:11 -0800 (PST)
In-Reply-To: <20170215062622.GO30338@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 7:26 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Feb 14, 2017 at 10:16:44AM +0100, Dmitry Vyukov wrote:
>>
>> I've run the repro with you patch and don't see the bug any more:
>>
>> Tested-by: Dmitry Vyukov <dvyukov@google.com>
>
> I've applied this to the ipsec tree now.
>
> Thanks for testing!


Hi Steffen,

Are you going to push this to Linus in this release? Still happens on
upstream branch.
