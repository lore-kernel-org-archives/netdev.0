From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 3/4] net: macb: macb.c changed to macb_main.c
Date: Tue, 06 Jun 2017 15:00:15 -0400 (EDT)
Message-ID: <20170606.150015.1247326483451270973.davem@davemloft.net>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
        <1496413661-21452-1-git-send-email-rafalo@cadence.com>
        <20170606183933.GA1205@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org
To: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170606183933.GA1205-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 6 Jun 2017 20:39:33 +0200

> On Fri, Jun 02, 2017 at 03:27:41PM +0100, Rafal Ozieblo wrote:
>>  drivers/net/ethernet/cadence/macb.c      | 3568 ------------------------------
>>  drivers/net/ethernet/cadence/macb_main.c | 3568 ++++++++++++++++++++++++++++++
> 
> You deleted macb.c, and so ...

Rename macb.c to macb_main.c

>> +macb-y	:= macb_main.o
>>  
>>  obj-$(CONFIG_MACB) += macb.o
> 
> how does this rule make sense any more?

He's adjusting the Makefile so that it build macb_main.c into macb.o
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
