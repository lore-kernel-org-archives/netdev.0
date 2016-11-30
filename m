From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Wed, 30 Nov 2016 11:35:06 -0600
Message-ID: <bf207ac4-0f9f-d4a7-14ac-704d93fb7764@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
 <20161130095632.GC28680@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161130095632.GC28680-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 11/30/2016 03:56 AM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:04:24PM -0600, Grygorii Strashko wrote:
>> Some CPTS instances, which can be found on KeyStone 2 1/10G Ethernet
>> Switch Subsystems, can control an external multiplexer that selects
>> one of up to 32 clocks for time sync reference (RFTCLK). This feature
>> can be configured through CPTS_RFTCLK_SEL register (offset: x08).
>>
>> Hence, introduce optional DT cpts_rftclk_sel poperty wich, if present,
>> will specify CPTS reference clock. The cpts_rftclk_sel should be
>> omitted in DT if HW doesn't support this feature. The external fixed
>> rate clocks can be defined in board files as "fixed-clock".
> 
> Can't you implement this using the clock tree, rather than an ad-hoc
> DT property?
> 

I've thought about this, but decided to move forward with this impl
 which is pretty simple. I will try.


-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
