From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Wed, 5 Jul 2017 08:59:37 -0700
Message-ID: <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
References: <20170704191615.6412-1-mahesh@bandewar.net> <20170705.092032.1482668095877350196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: mahesh@bandewar.net, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Eric Dumazet <edumazet@google.com>,
        ebiederm@xmission.com, linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:36579 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbdGEP77 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:59:59 -0400
Received: by mail-it0-f54.google.com with SMTP id m68so116357133ith.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 08:59:59 -0700 (PDT)
In-Reply-To: <20170705.092032.1482668095877350196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 1:20 AM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <mahesh@bandewar.net>
> Date: Tue,  4 Jul 2017 12:16:15 -0700
>
>> In almost every scenario the loopback device is brought UP after
>> initialization. So there is no point of bringing up the device in
>> DOWN state followed by device UP operation. This change exposed
>> another issue of fib-trie initialization which is corrected in the
>> first path.
>
> You use the word almost, which supports my position that someone may
> not want this.
>
> I also don't see it as so much of a burdon to bring the lo device up
> explicitly.  Systems have been having to do that since the beginning
> of time.
>
Systems have only one lo device (since ages) and that is usually taken
care at the boot time. Now with the namespaces it's not just one
device as it's per namespace and though not much this patch will
benefit a little. Probably we should ask a question - is it going to
have any bad effects? I couldn't find any and my RFC patch did not get
me any such feedback. As far as the good effects are concerned, it has
already found a bug (another patch in this series)! Also sometime back
I did experience weird behavior inside net-namespace if you forget to
bring-up the loopback device. I didn't pay too much attention as
bringing up the lo device fixed it.

> Sorry I'm not applying this.
