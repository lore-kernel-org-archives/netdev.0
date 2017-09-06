From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next:master 491/511] xt_hashlimit.c:undefined reference to `__aeabi_uldivmod'
Date: Wed, 6 Sep 2017 21:57:07 +0200
Message-ID: <CAK8P3a3PvU7F=kO=2cTmZaF_19nu9LzYtKnu-_+4+-WPBf=0ew@mail.gmail.com>
References: <201709062318.dBly2cas%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild-all@01.org, Networking <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37990 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752455AbdIFT5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 15:57:08 -0400
Received: by mail-oi0-f67.google.com with SMTP id d10so3705721oih.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 12:57:07 -0700 (PDT)
In-Reply-To: <201709062318.dBly2cas%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 5:27 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> Hi Arnd,
>
> It's probably a bug fix that unveils the link errors.

Correct.

>    net/netfilter/xt_hashlimit.o: In function `hashlimit_mt_common':
>>> xt_hashlimit.c:(.text+0x1f68): undefined reference to `__aeabi_uldivmod'

I actually wrote a patch for that yesterday, but it seems I forgot to submit it.
I've sent it now.

       Arnd
