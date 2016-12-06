From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Tue, 6 Dec 2016 14:43:49 -0600
Message-ID: <e67cfba3-7e57-cc1d-6654-00c0a5378382@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130100519.GD28680@localhost.localdomain>
 <20161206180857.GA20680@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161206180857.GA20680@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/06/2016 12:08 PM, Richard Cochran wrote:
> On Wed, Nov 30, 2016 at 11:05:19AM +0100, Richard Cochran wrote:
>> Can you adjust the frequency of the keystone devices in hardware?  If
>> so, then please implement it, and just disable PPS for the CPSW.
>>
>> The only reason I used the timecounter for frequency adjustment was
>> because the am335x HW is broken.  But this shouldn't hold back other
>> newer HW without the same silicon flaws.
>
> I am talking here about the ADPLLLJ units.  Are they usable on the
> keystone?
>
> If so, please implement the frequency adjustment with them.
>

No, I think it's not impossible (at least as I know now).
i'll drop this patch for now.

By the way, I've tested am335 (BBB)+ HW_TS_PUSH + PWM.
Seems works.

-- 
regards,
-grygorii
