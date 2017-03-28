From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH 0/4] uapi glibc compat: fix musl libc compatibility
Date: Tue, 28 Mar 2017 14:01:33 +0200
Message-ID: <0ec2bb3196283b5268da1e2e27962a1b@hauke-m.de>
References: <20170312220039.16885-1-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:54723 "EHLO mail.hauke-m.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdC1MBg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 08:01:36 -0400
In-Reply-To: <20170312220039.16885-1-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-12 23:00, Hauke Mehrtens wrote:
> The code from libc-compat.h depends on some glibc specific defines and
> causes compile problems with the musl libc. These patches remove some
> of the glibc dependencies. With these patches the LEDE (OpenWrt) base
> user space applications can be build with unmodified kernel headers and
> musl libc.
> 
> This was compile tested with the user space from LEDE (OpenWrt) with
> musl 1.1.16, glibc 2.25 and uClibc-ng 1.0.22.
> 
> David Heidelberger (1):
>   uapi/if_ether.h: prevent redefinition of struct ethhdr
> 
> Hauke Mehrtens (3):
>   uapi glibc compat: add libc compat code when not build for kernel
>   uapi glibc compat: fix build if libc defines IFF_ECHO
>   uapi glibc compat: Do not check for __USE_MISC
> 
>  include/uapi/linux/if_ether.h    |  3 +++
>  include/uapi/linux/libc-compat.h | 25 +++++++++++++++++++------
>  2 files changed, 22 insertions(+), 6 deletions(-)

Did I send this to the correct maintainer? I am unsure through which
maintainer this should go. I saw that some patches for the libc-compat.h
file went trough David Miller, so I tried the same.

Hauke
