From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [1/5] ath10k: Remove unused 'buf_len' variable
Date: Wed, 18 Jan 2017 14:37:24 +0000 (UTC)
Message-ID: <20170118143724.7A5FA6080C@smtp.codeaurora.org>
References: <196e46eee00fd3ebb56da1373c36f3dff66f2ae1.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <196e46eee00fd3ebb56da1373c36f3dff66f2ae1.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Commit 32653cf19554 removed the call to 'skb_trim(skb, buf_len)'
> in ath10k_wmi_event_mgmt_rx(), leaving the buf_len variable set but
> unused. Compiling with W=1 gives the following warning, fix it.
> drivers/net/wireless/ath/ath10k/wmi.c: In function ‘ath10k_wmi_event_mgmt_rx’:
> drivers/net/wireless/ath/ath10k/wmi.c:2280:6: warning: variable ‘buf_len’ set but not used [-Wunused-but-set-variable]
> 
> This is a harmless warning, and is only being fixed to reduce the
> noise with W=1 in the kernel.
> 
> Fixes: 32653cf19554 ("ath10k: implement intermediate event args")
> Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
> Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

These patches seem to be corrupted:

Applying: ath10k: Remove unused 'buf_len' variable
fatal: corrupt patch at line 13
error: could not build fake ancestor
Patch failed at 0001 ath10k: Remove unused 'buf_len' variable

When resending please also cc ath10k list:

https://wireless.wiki.kernel.org/en/users/drivers/ath10k/sources#submitting_patches

4 patches set to Changes Requested.

9444973 [1/5] ath10k: Remove unused 'buf_len' variable
9444935 [2/5] ath10k: Remove unused 'num_vdev_stats' variable
9444971 [4/5] ath10k: Removed unused 'dev' in ath10k_ahb_clock_enable()
9444975 [5/5] ath10k: Removed unused 'dev' in ath10k_ahb_resource_init

-- 
https://patchwork.kernel.org/patch/9444973/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
