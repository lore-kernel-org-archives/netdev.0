From: Diego Viola <diego.viola@gmail.com>
Subject: Re: Dell Inspiron 5558/0VNM2T and suspend/resume problem with r8169
Date: Wed, 1 Mar 2017 12:47:35 -0300
Message-ID: <CA+ToGPEvrHFukKkO1u9v0ndeCHepjGKs5v43MX7MmaEHgwdyag@mail.gmail.com>
References: <CA+ToGPHD9qRLer2aVFkNhRmJjKwEf6=sdwyqdW_X463H-Fnh3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:34563 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751821AbdCAQRT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 11:17:19 -0500
In-Reply-To: <CA+ToGPHD9qRLer2aVFkNhRmJjKwEf6=sdwyqdW_X463H-Fnh3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 12:44 PM, Diego Viola <diego.viola@gmail.com> wrote:
> My machine (a Dell Inspiron 5558 laptop) fails to resume from suspend
> unless I rmmod r8169 first.
>
> Another workaround is to do this before suspend:
>
> echo 0 > /sys/power/pm_async
>
> I've been reproducing the freeze like this:
>
> $ i3lock && systemctl suspend
>
> I would have to repeat this at least 5 times for the freeze to occur,
> but it seems to be easily reproducible.
>
> If I don't invoke i3lock, I cannot get the freeze to happen, but it
> seems to happen with other lockers also.
>
> I have tried Alt+SysRq+r and tried to switch to another TTY but the
> machine is always unresponsive, which indicates that it's a kernel
> panic.
>
> I have had a similar issue to this about a year ago with the jme
> driver and this was the fix:
>
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/jme.c?id=ee50c130c82175eaa0820c96b6d3763928af2241
>
> I haven't tried getting a kernel trace yet, but all seems to indicate
> the problem is caused by r8169, at least til now.
>
> Any ideas, please?
>
> Thanks,
> Diego

Sorry, I forgot to mention, I'm on Arch Linux (x86_64), kernel 4.9.11-1-ARCH.

Diego
