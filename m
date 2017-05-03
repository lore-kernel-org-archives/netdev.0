From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] netfilter: conntrack: Force inlining of build check to
 prevent build failure
Date: Wed, 3 May 2017 14:47:56 +0200
Message-ID: <CAMuHMdUxKE7cPVjg=1xyQ4nx=h5or2p2ZJk+xAkEOfK7fv3YYw@mail.gmail.com>
References: <1493813923-5441-1-git-send-email-geert@linux-m68k.org> <CAK8P3a23oEo1zYdFD2nSFzvEc6SF_hoW+4OBig_SY3C1oHJA+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36471 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdECMr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 08:47:58 -0400
In-Reply-To: <CAK8P3a23oEo1zYdFD2nSFzvEc6SF_hoW+4OBig_SY3C1oHJA+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On Wed, May 3, 2017 at 2:32 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wed, May 3, 2017 at 2:18 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> If gcc (e.g. 4.1.2) decides not to inline total_extension_size(), the
>> build will fail with:
>>
>>     net/built-in.o: In function `nf_conntrack_init_start':
>>     (.text+0x9baf6): undefined reference to `__compiletime_assert_1893'
>>
>> or
>>
>>     ERROR: "__compiletime_assert_1893" [net/netfilter/nf_conntrack.ko] undefined!
>>
>> Fix this by forcing inlining of total_extension_size().
>>
>> Fixes: b3a5db109e0670d6 ("netfilter: conntrack: use u8 for extension sizes again")
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
> I saw this as well when I tried building with "gcc-7 -Og", and came to the same
> conclusion.

Good^H^H^H^HBad to see it not only happens with ancient compilers ;-)

> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks!

Gr{oetje,eeting}s,

                        Geert
