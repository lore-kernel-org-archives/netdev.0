From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [v4.12 regression] netns: NULL deref in fib_sync_down_dev()
Date: Fri, 28 Jul 2017 10:28:16 -0700
Message-ID: <CAM_iQpXmUfdUzsu7Xpc2EjkePQCEjcP+irMkpc4bTDaWfAOVLw@mail.gmail.com>
References: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl> <20170728164331.GA5268@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33864 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdG1R2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:28:38 -0400
Received: by mail-wm0-f48.google.com with SMTP id t138so11267143wmt.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:28:37 -0700 (PDT)
In-Reply-To: <20170728164331.GA5268@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 9:43 AM, Ido Schimmel <idosch@idosch.org> wrote:
> On Fri, Jul 28, 2017 at 06:00:47PM +0200, Micha=C5=82 Miros=C5=82aw wrote=
:
>> Dear NetDevs,
>>
>> Before I go to bisecting, have you seen a following NULL dereference,
>> yet?  Where should I start looking?  It is triggered by deleting netns
>> (cut-down script attached - triggers every time).  This was working
>> correctly under v4.11.x.
>
> Thanks for the report. I just reproduced this on my system. I believe
> the problem is a missing NULL check for 'in_dev' in
> call_fib_nh_notifiers(). I'll test a fix.

But your commit 982acb97560c8118c2109504a22b0d78a580547d
is merged in v4.11-rc1. How could 4.11.x work correctly?
