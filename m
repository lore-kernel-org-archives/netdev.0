From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net] sched: cls_flower: remove from hashtable only in case
 skip sw flag is not set
Date: Mon, 28 Nov 2016 23:04:56 +0200
Message-ID: <CAJ3xEMhdyBfgtOgJqsY_x-Qr6hrhF01nm3VPL-kJnCofA0r3nA@mail.gmail.com>
References: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>, Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36492 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754243AbcK1VE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:04:57 -0500
Received: by mail-oi0-f46.google.com with SMTP id v84so166141360oie.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 13:04:57 -0800 (PST)
In-Reply-To: <1480344013-4812-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 4:40 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Be symmetric to hashtable insert and remove filter from hashtable only
> in case skip sw flag is not set.
>
> Fixes: e69985c67c33 ("net/sched: cls_flower: Introduce support in SKIP SW flag")

Amir, Jiri - what was the impact of running without this fix for the
last 3-4 kernels? I haven't seen any crashes, is that leaking took
place? or this is just a cleanup to make things more clear and
maintainable?
