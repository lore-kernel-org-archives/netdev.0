From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 12/15] net: davinci_mdio: document missed "ti,am4372-mdio"
 compat string
Date: Wed, 22 Jun 2016 13:26:45 +0300
Message-ID: <576A67E5.5050106@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
 <20160615115603.4897-13-grygorii.strashko@ti.com>
 <20160619143543.GA14844@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160619143543.GA14844@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/19/2016 05:35 PM, Rob Herring wrote:
> On Wed, Jun 15, 2016 at 02:56:00PM +0300, Grygorii Strashko wrote:
>> Document missed "ti,am4372-mdio" compat string used for TI am437x SoC
>> (am4372.dtsi).
>>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
>> ---
>>   Documentation/devicetree/bindings/net/davinci-mdio.txt | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/davinci-mdio.txt b/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> index 0369e25..f2bba50 100644
>> --- a/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> +++ b/Documentation/devicetree/bindings/net/davinci-mdio.txt
>> @@ -2,7 +2,8 @@ TI SoC Davinci/Keystone2 MDIO Controller Device Tree Bindings
>>   ---------------------------------------------------
>>   
>>   Required properties:
>> -- compatible		: Should be "ti,davinci_mdio" or "ti,keystone_mdio"
>> +- compatible		: Should be "ti,davinci_mdio", "ti,keystone_mdio",
>> +			  "ti,am4372-mdio"
> 
> This is still an OR relationship?

I think it's AND relation. It should be smth. like this:
 [SoC,][IP family,] "ti,davinci_mdio"
where "ti,davinci_mdio" is mandatory always
 [IP family] - mandatory for IP/SOC family and can be "ti,keystone_mdio" or "ti,cpsw-mdio" (last one is added by subsequent patch)
 [SoC] - mandatory for SoC. now can be "ti,am4372-mdio"

I can update it as below:
- compatible		: Should be "ti,davinci_mdio"  
			  and "ti,keystone_mdio" for Keystone 2 SoCs
 			  and "ti,am4372-mdio" for am472x SoC
and in subsequent patch
			 and "ti,cpsw-mdio" for am335x, am472x, am57xx/dra7, dm814x SoCs
			 and "ti,am4372-mdio" for am472x SoC



> 
> It's preferred to list one per line.

ok



-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
