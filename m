From: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 5/6] ARM: AM43xx: clk: Change the cpts ref clock source
 to dpll_core_m5 clk
Date: Tue, 29 Apr 2014 09:58:36 +0530
Message-ID: <535F2A74.9060908@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com> <1398658225-25873-6-git-send-email-george.cherian@ti.com> <20140428071034.GB4380@netboy> <535E4FDC.70306@ti.com> <20140428161856.GB4266@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>,
	<mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	<zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <balbi-l0cyMroinI0@public.gmane.org>, <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	<t-kristo-l0cyMroinI0@public.gmane.org>, <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<pawel.moll-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	<bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140428161856.GB4266@netboy>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 4/28/2014 9:48 PM, Richard Cochran wrote:
> On Mon, Apr 28, 2014 at 06:25:56PM +0530, George Cherian wrote:
>> In beagle bone white (AM335x)  CPTS has a choice of 2 clocksource
>> -dpll_core_m5_ck
>> -dpll_core_m4_ck
>> and by default  dpll_core_m5_ck is used. Where as in AM437x the
>> default clocksource used is dpll_core_m4_ck .
> Is your patch changing the default clock for am335x?
No
>
> If yes, it shouldn't.
> If no, then the patch description should say so.
I am modifying the file

drivers/clk/ti/clk-43xx.c for am33xx its drivers/clk/ti/clk-33xx.c

> Thanks,
> Richard
>
>   


-- 
-George

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
