From: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 1/2] dt-binding: ptp: add bindings document for dte
 based ptp clock
Date: Mon, 19 Jun 2017 09:50:27 -0700
Message-ID: <8a45ea64-5a0e-6ecf-1e1d-ab8e85aa3115@broadcom.com>
References: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
 <1497299161-6458-2-git-send-email-arun.parameswaran@broadcom.com>
 <20170618140449.aek7vag22i5lnbhl@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170618140449.aek7vag22i5lnbhl@rob-hp-laptop>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David, Rob,
I will address all of Rob's comments below.

Since a part of the patch was applied to 'net-next', would you like me to
send a new patch (based on the applied one), or a 'V2' of this patch ?

Thanks
Arun

On 17-06-18 07:04 AM, Rob Herring wrote:
> On Mon, Jun 12, 2017 at 01:26:00PM -0700, Arun Parameswaran wrote:
>> Add device tree binding documentation for the Broadcom DTE
>> PTP clock driver.
>>
>> Signed-off-by: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> ---
>>  Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>>
>> diff --git a/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>> new file mode 100644
>> index 0000000..07590bc
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
>> @@ -0,0 +1,13 @@
>> +* Broadcom Digital Timing Engine(DTE) based PTP clock driver
> 
> Bindings describe h/w, not drivers.
> 
>> +
>> +Required properties:
>> +- compatible: should be "brcm,ptp-dte"
> 
> Looks too generic. You need SoC specific compatible strings.
> 
>> +- reg: address and length of the DTE block's NCO registers
>> +
>> +Example:
>> +
>> +ptp_dte: ptp_dte@180af650 {
> 
> Don't use '_' in node names.
> 
>> +	compatible = "brcm,ptp-dte";
>> +	reg = <0x180af650 0x10>;
>> +	status = "okay";
>> +};
>> -- 
>> 1.9.1
>>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
