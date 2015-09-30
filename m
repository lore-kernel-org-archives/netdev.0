From: Arun Parameswaran <aparames-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/4] dt-bindings: net: Broadcom iProc MDIO bus driver
 device tree binding
Date: Wed, 30 Sep 2015 14:45:39 -0700
Message-ID: <560C5803.1040907@broadcom.com>
References: <1443645163-2822-1-git-send-email-arunp@broadcom.com> <1443645163-2822-2-git-send-email-arunp@broadcom.com> <560C55C2.3010906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm-kernel-feedback-list <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <560C55C2.3010906-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 15-09-30 02:36 PM, Florian Fainelli wrote:
> On 30/09/15 13:32, Arun Parameswaran wrote:
>> Add device tree binding documentation for the Broadcom iProc MDIO
>> bus driver.
>>
>> Signed-off-by: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/brcm,iproc-mdio.txt    | 23 ++++++++++++++++++++++
>>  1 file changed, 23 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt b/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
>> new file mode 100644
>> index 0000000..689f97c
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/brcm,iproc-mdio.txt
>> @@ -0,0 +1,23 @@
>> +* Broadcom iProc MDIO bus controller
>> +
>> +Required properties:
>> +- compatible: should be "brcm,iproc-mdio"
>> +- reg: address and length of the register set for the MDIO interface
>> +- #size-cells: must be 1
>> +- #address-cells: must be 0
>> +
>> +Child nodes of this MDIO bus controller node are standard Ethernet PHY device
>> +nodes as described in Documentation/devicetree/bindings/net/phy.txt
>> +
>> +Example:
>> +
>> +mdio@0x18002000 {
> Sorry for not catching this earlier, you might want to drop the leading
> 0x here from your example, other than that:
>
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Will fix this.

Thanks,

Arun

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
