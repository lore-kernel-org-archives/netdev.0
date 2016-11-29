From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: adm80211: Removed unused 'io_addr' 'mem_addr' variables
Date: Tue, 29 Nov 2016 15:32:06 +0000 (UTC)
Message-ID: <20161129153206.0E7EF611A6@smtp.codeaurora.org>
References: <20161124064045.GA8836@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161124064045.GA8836-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Initial commit cc0b88cf5ecf ([PATCH] Add adm8211 802.11b wireless driver)
> introduced variables mem_addr and io_addr in adm80211_probe() that are
> set but not used. Compiling with W=1 gives the following warnings,
> fix them.
> 
> drivers/net/wireless/admtek/adm8211.c: In function ‘adm8211_probe’:
> drivers/net/wireless/admtek/adm8211.c:1769:15: warning: variable ‘io_addr’ set but not used [-Wunused-but-set-variable]
>   unsigned int io_addr, io_len;
>                ^
> drivers/net/wireless/admtek/adm8211.c:1768:16: warning: variable ‘mem_addr’ set but not used [-Wunused-but-set-variable]
>   unsigned long mem_addr, mem_len;
>                 ^
> 
> These are harmless warnings and are only being fixed to reduce the
> noise with W=1 in the kernel. The calls to pci_resource_start do not
> have any side-effects and are safe to remove.
> 
> Fixes: cc0b88cf5ecf ("[PATCH] Add adm8211 802.11b wireless driver")
> Cc: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
> Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

The patch failed to apply:

fatal: corrupt patch at line 14
Applying: adm80211: Removed unused 'io_addr' 'mem_addr' variables
Repository lacks necessary blobs to fall back on 3-way merge.
Cannot fall back to three-way merge.
Patch failed at 0001 adm80211: Removed unused 'io_addr' 'mem_addr' variables

Patch set to Changes Requested.

-- 
https://patchwork.kernel.org/patch/9444901/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
