From: Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
 Ultrascale+ MPSoC
Date: Wed, 10 Aug 2016 08:11:27 +0200
Message-ID: <49580e8c-35cc-99b3-e77e-1c58107e6ffb@xilinx.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
 <1441958258-35441-3-git-send-email-harinik@xilinx.com>
 <CAFcVECLfXL-=efbUhNeKhiFQgtfv6Z1+JJckg+js7DM-LfFeSw@mail.gmail.com>
 <99d6c0ce-c3b9-a919-cedb-0af954bac388@atmel.com>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A1C4205@XAP-PVEXMBX02.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org"
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Anirudha Sarangi <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Andrei Pistirica <Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <03CA77BA8AF6F1469AEDFBDA1322A7B74A1C4205-4lKfpRxZ5ekkx2a1wsGfbYg+Gb3gawCHQz34XiSyOiE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

just a note: Here is the link to public Linux repo
https://github.com/Xilinx/linux-xlnx

Thanks,
Michal


On 9.8.2016 18:56, Punnaiah Choudary Kalluri wrote:
> Hi Nicolas,
> 
>  1588 implementation in cadence GEM IP we have in Zynq Ultascale+ MPSoC is
> Different to the one in Zynq SOC.
> 
> In earlier version, all timestamp values will be stored in registers and there is no specific
> Mechanism to distinguish the received ethernet frame that contains time stamp information
> Other than parsing the frame for PTP packet type.
> 
> We have basic implementation for earlier version in our out of tree driver, which is going to be deprecated
> Soon. You could also check the below driver for 1588 support.
> https://gitenterprise.xilinx.com/Linux/linux-xlnx/blob/master/drivers/net/ethernet/xilinx/xilinx_emacps.c
> 
> 
> Regards,
> Punnaiah
> 
>> -----Original Message-----
>> From: Nicolas Ferre [mailto:nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org]
>> Sent: Tuesday, August 09, 2016 10:10 PM
>> To: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>; Harini Katakam
>> <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; Andrei Pistirica <Andrei.Pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
>> Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Boris Brezillon <boris.brezillon@free-
>> electrons.com>; alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org;
>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Punnaiah Choudary Kalluri
>> <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>; Anirudha
>> Sarangi <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
>> Subject: Re: [RFC PATCH 2/3] net: macb: Add support for 1588 for Zynq
>> Ultrascale+ MPSoC
>>
>> Le 21/09/2015 à 19:49, Harini Katakam a écrit :
>>> On Fri, Sep 11, 2015 at 1:27 PM, Harini Katakam
>>> <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
>>>> Cadence GEM in Zynq Ultrascale+ MPSoC supports 1588 and provides a
>>>> 102 bit time counter with 48 bits for seconds, 30 bits for nsecs and
>>>> 24 bits for sub-nsecs. The timestamp is made available to the SW through
>>>> registers as well as (more precisely) through upper two words in
>>>> an extended BD.
>>>>
>>>> This patch does the following:
>>>> - Adds MACB_CAPS_TSU in zynqmp_config.
>>>> - Registers to ptp clock framework (after checking for timestamp support
>> in
>>>>   IP and capability in config).
>>>> - TX BD and RX BD control registers are written to populate timestamp in
>>>>   extended BD words.
>>>> - Timer initialization is done by writing time of day to the timer counter.
>>>> - ns increment register is programmed as NS_PER_SEC/TSU_CLK.
>>>>   For a 24 bit subns precision, the subns increment equals
>>>>   remainder of (NS_PER_SEC/TSU_CLK) * (2^24).
>>>>   TSU (Time stamp unit) clock is obtained by the  driver from devicetree.
>>>> - HW time stamp capabilities are advertised via ethtool and macb ioctl is
>>>>   updated accordingly.
>>>> - For all PTP event frames, nanoseconds and the lower 5 bits of seconds
>> are
>>>>   obtained from the BD. This offers a precise timestamp. The upper bits
>>>>   (which dont vary between consecutive packets) are obtained from the
>>>>   TX/RX PTP event/PEER registers. The timestamp obtained thus is
>> updated
>>>>   in skb for upper layers to access.
>>>> - The drivers register functions with ptp to perform time and frequency
>>>>   adjustment.
>>>> - Time adjustment is done by writing to the 1558_ADJUST register.
>>>>   The controller will read the delta in this register and update the timer
>>>>   counter register. Alternatively, for large time offset adjustments,
>>>>   the driver reads the secs and nsecs counter values, adds/subtracts the
>>>>   delta and updates the timer counter. In order to be as precise as
>> possible,
>>>>   nsecs counter is read again if secs has incremented during the counter
>> read.
>>>> - Frequency adjustment is not directly supported by this IP.
>>>>   addend is the initial value ns increment and similarly addendesub.
>>>>   The ppb (parts per billion) provided is used as
>>>>   ns_incr = addend +/- (ppb/rate).
>>>>   Similarly the remainder of the above is used to populate subns
>> increment.
>>>>   In case the ppb requested is negative AND subns adjustment greater
>> than
>>>>   the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
>>>>   positive accordingly.
>>>>
>>>> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>:
>>>> ---
>>>>  drivers/net/ethernet/cadence/macb.c |  372
>> ++++++++++++++++++++++++++++++++++-
>>>>  drivers/net/ethernet/cadence/macb.h |   64 ++++++
>>>>  2 files changed, 428 insertions(+), 8 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/cadence/macb.c
>> b/drivers/net/ethernet/cadence/macb.c
>>>> index bb2932c..b531008 100644
>>>> --- a/drivers/net/ethernet/cadence/macb.c
>>>> +++ b/drivers/net/ethernet/cadence/macb.c
>>>> @@ -30,6 +30,8 @@
>>>>  #include <linux/of_device.h>
>>>>  #include <linux/of_mdio.h>
>>
>> [..]
>>
>>>> +       unsigned int            ns_incr;
>>>> +       unsigned int            subns_incr;
>>>>  };
>>>>
>>>>  static inline bool macb_is_gem(struct macb *bp)
>>>> --
>>>> 1.7.9.5
>>>
>>> Ping
>>>
>>> Thanks.
>>
>> Harini,
>>
>> I come back to this patch of last year and I'm sorry about being so late
>> answering you.
>>
>> Andrei who is added to the discussion will have some time to deal with
>> this feature and we would like to make some progress with it. He already
>> had some work done on his side before I recall your email.
>>
>> So, could you please re-send your original 1588 patch with Andrei in
>> copy so that we can all (re-)start the discussion and progress for
>> adding this feature.
>>
>> We must also note that some hardware differences between our platforms
>> may have an impact on the code and how we implement things (as
>> highlighted on this forum:
>> http://www.at91.com/discussions/viewtopic.php/f,12/t,25462.html).
>> Anyway, we'll overcome this and have a widely tested solution at the end
>> of the day!
>>
>> Thanks for your patience, bye!
>>
>> PS: for some reason, I only have this "ping" part of your email but not
>> the original one
>> --
>> Nicolas Ferre

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
