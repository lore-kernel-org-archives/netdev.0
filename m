From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Add hardware PTP support.
Date: Wed, 29 Mar 2017 09:39:14 -0700 (PDT)
Message-ID: <20170329.093914.152103359543418375.davem@davemloft.net>
References: <1490796051-28527-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
To: rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490796051-28527-1-git-send-email-rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Date: Wed, 29 Mar 2017 15:00:51 +0100

> This patch is based on original Harini's patch and Andrei's patch,
> implemented in aseparate file to ease the review/maintanance
> and integration with other platforms.
> 
> In case that macb is compiled as a module, it has been renamed to
> cadence-macb.ko to avoid naming confusion in Makefile.
> 
> This driver does support GEM-GXL:
> - Enable HW time stamp
> - Register ptp clock framework
> - Initialize PTP related registers
> - Updated dma buffer descriptor read/write mechanism
> - HW time stamp on the PTP Ethernet packets are received using the
>   SO_TIMESTAMPING API. Where timers are obtained from the dma buffer
>   descriptors
> - Added tsu_clk to device tree
> 
> Note: Patch on net-next, on March 15th.
> 
> Signed-off-by: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>

Your subject should provide a proper subsystem prefix such as
"cadence: " after "[PATCH] ".

Also, March 15th is nearly half a month ago, you should generate
patches against the current tree.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
