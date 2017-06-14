From: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte
 based ptp clock
Date: Wed, 14 Jun 2017 11:33:25 -0700
Message-ID: <55054c58-b493-7225-4aec-84f9e1c6e022@broadcom.com>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
 <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
 <20170613050947.GA1684@localhost.localdomain>
 <cb008f0f-1585-653e-0b89-47478f9f4734@broadcom.com>
 <a4586d75-2aca-94f3-ab7a-fc94c9dc5a4a@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Ray Jui <ray.jui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a4586d75-2aca-94f3-ab7a-fc94c9dc5a4a-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 17-06-14 11:18 AM, Ray Jui wrote:
> 
> 
> On 6/13/17 10:46 AM, Arun Parameswaran wrote:
>>
>> Hi Richard,
>>
>> On 17-06-12 10:09 PM, Richard Cochran wrote:
>>> On Mon, Jun 12, 2017 at 01:26:00PM -0700, Arun Parameswaran wrote:
>>>> +Example:
>>>> +
>>>> +ptp_dte: ptp_dte@180af650 {
>>>> +	compatible = "brcm,ptp-dte";
>>>> +	reg = <0x180af650 0x10>;
>>>> +	status = "okay";
>>>> +};
>>> This patch set looks okay, as far as it goes, but how does one
>>> actually use the clock?
>>>
>>> How does one connect this node to an Ethernet MAC, for example?
>> In some of the SoC's, the DTE's NCO is synced in hardware with the Ethernet's
>> 1588 Shim NCO (used for time-stamping the packets). We are working on getting
>> all the future SoC's synced this way (for Ethernet).
>>
> 
> So apparently you do not need any phandle based DT binding defined for
> the connection between the Ethernet device node and the PTP device node?
> 
Correct. This driver doesn't need any phandle.

The Ethernet/Switch driver, in the SoC's where the hardware link is not
available, might need the phandle to this driver.

>> In other scenarios, we use an user-space app to perform the sync based on
>> time-stamps from external hardware sources like the Wi-Fi.
>>> Thanks,
>>> Richard
>>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
