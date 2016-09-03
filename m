From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: wl3501_cs: Add spinlock to wl3501_reset
Date: Sat,  3 Sep 2016 10:01:36 +0000 (UTC)
Message-ID: <20160903100136.BB94A6201C@smtp.codeaurora.org>
References: <1470130913-5218-1-git-send-email-andrianov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org,
        vaishali.thakkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
To: Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470130913-5218-1-git-send-email-andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org> wrote:
> Likely wl3501_reset should acquire spinlock as wl3501_{open, close}.
> One of calls of wl3501_reset has been already protected.
> The others were unprotected and might lead to a race condition.
> The patch adds spinlock into the wl3501_reset and removes it from 
> wl3501_tx_timeout.
> 
> Found by Linux Driver Verification project (linuxtesting.org)
> 
> Signed-off-by: Pavel Andrianov <andrianov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
> Acked-by: Vaishali Thakkar <vaishali.thakkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

bd6b0242652a wl3501_cs: Add spinlock to wl3501_reset

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9255415/
