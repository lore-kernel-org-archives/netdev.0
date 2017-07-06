From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 0/2] bring UP loopback device at initialziation
Date: Thu, 6 Jul 2017 11:40:34 -0700
Message-ID: <CAM_iQpW-Z8jsK_kSMkqUKY-aVr01nAf6V8HzSdxCzGTaNru2yQ@mail.gmail.com>
References: <20170704191615.6412-1-mahesh@bandewar.net> <20170705.092032.1482668095877350196.davem@davemloft.net>
 <CAF2d9jjZ0XJDo3qYKnNgeMMLQXgUwt5ga8p_cWd5x-DjhzwWyA@mail.gmail.com>
 <20170705.170524.241248681076978527.davem@davemloft.net> <CAF2d9jhTujK0J53DODxCp+0yYnR2RTz7rVGaJE=xeN0-9k4C3g@mail.gmail.com>
 <871spuek9i.fsf@xmission.com> <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34598 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752351AbdGFSk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 14:40:56 -0400
Received: by mail-wr0-f193.google.com with SMTP id k67so2363432wrc.1
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 11:40:55 -0700 (PDT)
In-Reply-To: <CAF2d9jjsRXnuPz3WKSRZK5ctj_c2BMBcWfiWbe4vxesGA8fNgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 4:01 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
>
> Now that you have made me aware of some use cases that do want the
> loopback device to be DOWN, could we use a global sysctl to dictate
> the loopback behavior during init? e.g.

Yeah, it is never about which way is better, it is all about if we could br=
eak
the existing assumption. This is a similar situation to the
inconsistent behavior
of the per-netns sysctl's between IPv4 and IPv6, there were multiple fixes
or complains about it in this mailing list, but we still don't change it ye=
t.
