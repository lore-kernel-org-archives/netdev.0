From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [3/5] ath10k: Remove unused wmi_p2p_noa_descriptor 'noa' in
 wmi-tlv
Date: Fri, 13 Jan 2017 15:01:57 +0100
Message-ID: <ab6e49f1d0f2446c8a411cfd688ab0e9@euamsexm01a.eu.qualcomm.com>
References: <99d0ff42e57d5f62560e72d926b4d69d5d7c418b.1479974100.git.kirtika@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Raja Mani <rmani-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
        "Michal Kazior" <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <99d0ff42e57d5f62560e72d926b4d69d5d7c418b.1479974100.git.kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kirtika Ruchandani <kirtika.ruchandani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Commit ca996ec56608 (ath10k: implement wmi-tlv backend)
> introduced ath10k_wmi_tlv_op_gen_vdev_start() where
> 'struct wmi_p2p_noa_descriptor *noa' is defined and set but not used.
> Compiling with W=1 gives the following warning, fix it.
> drivers/net/wireless/ath/ath10k/wmi-tlv.c: In function ‘ath10k_wmi_tlv_op_gen_vdev_start’:
> drivers/net/wireless/ath/ath10k/wmi-tlv.c:1647:33: warning: variable ‘noa’ set but not used [-Wunused-but-set-variable]
> 
> Fixes: ca996ec56608 ("ath10k: implement wmi-tlv backend")
> Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
> Cc: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> Signed-off-by: Kirtika Ruchandani <kirtika-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

No response to Michal's comment by the author

Patch set to Changes Requested.

-- 
https://patchwork.kernel.org/patch/9444937/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
