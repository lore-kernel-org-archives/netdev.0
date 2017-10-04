From: James Chapman <jchapman@katalix.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Wed, 4 Oct 2017 08:49:51 +0100
Message-ID: <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3> <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com> <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>
To: SviMik <svimik@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:52454 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbdJDHt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 03:49:57 -0400
Received: from mail-pg0-f41.google.com (mail-pg0-f41.google.com [74.125.83.41])
        (Authenticated sender: james)
        by mail.katalix.com (Postfix) with ESMTPSA id AD5E7A881E
        for <netdev@vger.kernel.org>; Wed,  4 Oct 2017 08:49:53 +0100 (BST)
Received: by mail-pg0-f41.google.com with SMTP id p5so6092001pgn.7
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 00:49:53 -0700 (PDT)
In-Reply-To: <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 October 2017 at 08:27, James Chapman <jchapman@katalix.com> wrote:
> On 2 October 2017 at 19:35, SviMik <svimik@gmail.com> wrote:
>> Hi, James!
>>
>> No, I'm suffering from kernel panics since I started using 4.x
>> kernels.
> It's interesting that you are seeing l2tp issues since switching to
> 4.x kernels. Are you able to try earlier kernels to find the latest
> version that works? I'm curious whether things broke at v3.15.

It's possible that this may be fixed by a patch that is already
upstream and merged for v4.14. The fix is from Guillaume Nault:

f3c66d4 l2tp: prevent creation of sessions on terminated tunnels

If it's possible that the L2TP server may try to create a session in a
tunnel that is being closed, this bug would be exposed.

Guillaume's fix isn't yet pushed to stable releases. Are you able to
try a v4.14-rc build?
