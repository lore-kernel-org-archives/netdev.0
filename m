From: SviMik <svimik@gmail.com>
Subject: Re: Fw: [Bug 197099] New: Kernel panic in interrupt [l2tp_ppp]
Date: Fri, 6 Oct 2017 07:45:47 +0300
Message-ID: <CA++DawbbfQq1ZGB_x5t4a9mhkkptnDfcDxtCXgHYfGpY=8q83g@mail.gmail.com>
References: <20171001102110.24184f1b@xeon-e3> <CAEwTi7QkF73cc1hShzOoM9bzb5mBzyFW8t68OCn+XECrJ9d61Q@mail.gmail.com>
 <1506952566.8061.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CA++DawY6CPh5S8A7pPE+-nwwGxJ4=pKL_MkXT_Q5TZb8xFnCjA@mail.gmail.com>
 <CAEwTi7S3-B81bNxyWq8j4hUpXyqNnTADReYoKoGF-V4wC5OBkQ@mail.gmail.com> <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:45985 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdJFEps (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:45:48 -0400
Received: by mail-ua0-f169.google.com with SMTP id l40so10390200uah.2
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 21:45:48 -0700 (PDT)
In-Reply-To: <CAEwTi7SS7qsbV19NsPGwdiwTcejxygUEqQi-_MJ07uMec0CY9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-10-04 10:49 GMT+03:00 James Chapman <jchapman@katalix.com>:
> On 3 October 2017 at 08:27, James Chapman <jchapman@katalix.com> wrote:
>> For capturing complete oops messages, have you tried setting up
>> netconsole? You might also find the full text in the syslog on reboot.

Why, thank you! You've just told me that Santa Claus exists :)
I've set up netconsole on 93 of my servers, and hope starting from
tomorrow I'll have more pretty kernel panic reports, and get them even
from servers where I had never had a chance to capture the console
before.

>> It's interesting that you are seeing l2tp issues since switching to
>> 4.x kernels. Are you able to try earlier kernels to find the latest
>> version that works? I'm curious whether things broke at v3.15.

I'll try, but it will take some time to grab enough statistics. The
bug is relatively rare, only few panics per day on the whole bunch of
93 servers.

> It's possible that this may be fixed by a patch that is already
> upstream and merged for v4.14. The fix is from Guillaume Nault:
>
> f3c66d4 l2tp: prevent creation of sessions on terminated tunnels
>
> If it's possible that the L2TP server may try to create a session in a
> tunnel that is being closed, this bug would be exposed.
>
> Guillaume's fix isn't yet pushed to stable releases. Are you able to
> try a v4.14-rc build?

Sorry, I'm not skilled enough to build a kernel for CentOS on my own.
Will wait till it appears in elrepo. The latest version there is
currently 4.13.5. Meanwhile I'll try to switch to 3.10 and see how it
works.

I have also captured few more kernel panics in the last few days.
Please see if they are related to this bug:
http://svimik.com/hdmmsk1kp2.png
http://svimik.com/hdmmsk1kp3.png
http://svimik.com/hdmmsk1kp4.png
http://svimik.com/hdmmsk2kp6.png
