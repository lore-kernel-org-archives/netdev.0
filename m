From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Wed, 5 Jul 2017 10:48:56 -0700
Message-ID: <CAM_iQpXB6NSKK8ibE_r2SqLaLTsUQicVE8LqmdQ7qAz8-+AH_Q@mail.gmail.com>
References: <20170704191615.6412-1-mahesh@bandewar.net> <20170705.092032.1482668095877350196.davem@davemloft.net>
 <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        linux-netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36556 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdGERtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 13:49:23 -0400
Received: by mail-wm0-f66.google.com with SMTP id y5so33981679wmh.3
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 10:49:17 -0700 (PDT)
In-Reply-To: <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 8:59 AM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
> Systems have only one lo device (since ages) and that is usually taken
> care at the boot time. Now with the namespaces it's not just one
> device as it's per namespace and though not much this patch will
> benefit a little. Probably we should ask a question - is it going to
> have any bad effects? I couldn't find any and my RFC patch did not get
> me any such feedback. As far as the good effects are concerned, it has
> already found a bug (another patch in this series)! Also sometime back
> I did experience weird behavior inside net-namespace if you forget to
> bring-up the loopback device. I didn't pay too much attention as
> bringing up the lo device fixed it.
>

I wonder if it is too late to change this since this behavior is probably
from the beginning of network namespace. A networkless netns is also
useful at least for testing purpose, we do use it as a sandbox.
