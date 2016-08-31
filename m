From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 14:19:26 -0500
Message-ID: <57C72DBE.5000802@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <CAKoUAr=Z56VxzW=zHu7r9ossdXHQ6xpeYdR5jwhv38zkV_eKFQ@mail.gmail.com>
 <57C1FB42.104@codeaurora.org> <57C728B4.7070303@codeaurora.org>
 <60d13549-f9ea-694b-1030-0c610e0d9722@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <60d13549-f9ea-694b-1030-0c610e0d9722-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> if these are truly 64-bits stats, how come you are using a single
> readl_* to access them? Or is the u64 rx_err_addr just used as temporary
> storage and aligned to the largest size you need to deal with?

"*stats_itr += val;" takes the 32-bit val, zero-extends it to 64 bits, 
and then adds that to the corresponding 64-bit field in emac_stats.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
