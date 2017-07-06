From: Richard Leitner <richard.leitner-WcANXNA0UjBBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: fsl: add phy reset after clk enable
 option
Date: Thu, 6 Jul 2017 16:33:47 +0200
Message-ID: <109f44aa-87ed-6a9c-b557-8dabb2958c8c@skidata.com>
References: <1499346330-12166-1-git-send-email-richard.leitner@skidata.com>
 <1499346330-12166-2-git-send-email-richard.leitner@skidata.com>
 <20170706135557.GC8810@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <fugang.duan-3arQi8VN3Tc@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dev-M/VWbR8SM2SsTnJN9+BGXg@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170706135557.GC8810-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 07/06/2017 03:55 PM, Andrew Lunn wrote:
>> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
>> index 6f55bdd..1766579 100644
>> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
>> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
>> @@ -23,6 +23,9 @@ Optional properties:
>>  - phy-handle : phandle to the PHY device connected to this device.
>>  - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
>>    Use instead of phy-handle.
>> +- phy-reset-after-clk-enable : If present then a phy reset and configuration
>> +  will be performed everytime after the clocks are enabled. This is required
>> +  for some PHYs to work properly.
> 
> It sounds like this issue will apply to any LAN8710 which has its
> clock fiddled with. So this should be a centrally documented property,
> which any MAC driver can implement. Please move the above text to
> ethernet.txt, and instead have:
> 
>  - phy-reset-after-clk-enable : See ethernet.txt

I haven't tested it on any other platform than an i.MX6, but IMHO you're
right. It sounds reasonable that it affects any SoC which is messing
around with the clock and not performing a reset by default.

Thanks for that hint!
I'll include that in the v2.

>  Thanks
> 	 Andrew
> 

regards,
Richard.L
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
