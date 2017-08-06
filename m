From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: NULL pointer deref bring up interfaces
Date: Sun, 6 Aug 2017 13:54:37 -0700
Message-ID: <20170806135437.23330bbf@xeon-e3>
References: <CAEMnpcuw8Ow37_amPQtm66EkLwEpTDHWQFoe5UmFXzczYeQ-1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rafael Cepeda <rcepeda1993@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36683 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751342AbdHFUyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 16:54:40 -0400
Received: by mail-pg0-f54.google.com with SMTP id v77so26239838pgb.3
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 13:54:40 -0700 (PDT)
In-Reply-To: <CAEMnpcuw8Ow37_amPQtm66EkLwEpTDHWQFoe5UmFXzczYeQ-1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 6 Aug 2017 12:29:13 -0500
Rafael Cepeda <rcepeda1993@gmail.com> wrote:

> Just upgraded to 4.13rc2, rebooted, and my system crashed at my
> netmount init script; says RIP is NULL, I am guessing a bad func call.
> I immediately thought missing firmware in kernel, my kernel builds
> firmware in it, so I upgraded my firmware to latest on git.kernel and
> made sure I had no warnings in dmesg about missing firmware. Still, I
> receive this NULL pointer in the IP. If I disable my netmount on boot,
> I can login, but can not bring up my interfaces, still get a RIP err
> in kernel logs and cpu load sky-rockets...the issue still exists on
> rc3.
> 
> Linux-Regression-ID: lr#084be9
> 
> I am willing to help and provide as much info as possible, thank you.

You need to post:
 1. Kernel config -- since you are building your own kernel.
 2. Hardware -- lspci output
 3. Kernel log if possible (use serial console).

Ideally, you can bisect it down to the commit that causes the problem.
