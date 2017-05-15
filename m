From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net v2] qed: Fix uninitialized data in aRFS infrastructure
Date: Mon, 15 May 2017 16:35:34 +0200
Message-ID: <CAK8P3a2HNAPOrwr+RQ0gGkjs64aKr3=C2VgNwqgqN9+yaNa6JQ@mail.gmail.com>
References: <1494753683-3429-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33348 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934356AbdEOOff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:35:35 -0400
Received: by mail-oi0-f44.google.com with SMTP id w10so133007957oif.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 07:35:35 -0700 (PDT)
In-Reply-To: <1494753683-3429-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 14, 2017 at 11:21 AM, Yuval Mintz <Yuval.Mintz@cavium.com> wrote:
> Current memset is using incorrect type of variable, causing the
> upper-half of the strucutre to be left uninitialized and causing:
>
>   ethernet/qlogic/qed/qed_init_fw_funcs.c: In function 'qed_set_rfs_mode_disable':
>   ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void *)&ramline+4)' is used uninitialized in this function [-Werror=uninitialized]
>
> Fixes: d51e4af5c209 ("qed: aRFS infrastructure support")
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

> I don't see the original warning you've reported [probably due to
> compiler differences], so other than via code reading I couldn't
> actually test this. Can you please compile-test this one?

I don't see the warning any more either with the compiler and defconfig
I used last time, maybe some compiler flags have changed in the
meantime.

Anyway, your patch is definitely required to make it work correctly, so

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

       Arnd
