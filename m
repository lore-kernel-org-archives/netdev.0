From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] of_mdio: Add "broadcom,bcm5241" to the whitelist.
Date: Fri, 17 Feb 2017 13:41:21 -0800
Message-ID: <3537f379-4d93-d8fe-6892-cae09ce0b43a@caviumnetworks.com>
References: <20170217200412.11680-1-david.daney@cavium.com>
 <799d4300-64f0-1fb2-2ef7-870a4d5fac20@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Daney <david.daney@cavium.com>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <799d4300-64f0-1fb2-2ef7-870a4d5fac20@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2017 12:09 PM, Florian Fainelli wrote:
> On 02/17/2017 12:04 PM, David Daney wrote:
>> Some Cavium dev boards have firmware which doesn't supply a proper
>> ethernet-phy-ieee802.3-c22" compatible property.  Restore these boards
>> to working order by whitelisting this compatible value.
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
>
>> ---
>>  drivers/of/of_mdio.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>> index 262281b..0b29798 100644
>> --- a/drivers/of/of_mdio.c
>> +++ b/drivers/of/of_mdio.c
>> @@ -147,6 +147,7 @@ EXPORT_SYMBOL(of_mdio_parse_addr);
>>   */
>>  static const struct of_device_id whitelist_phys[] = {
>>  	{ .compatible = "brcm,40nm-ephy" },
>> +	{ .compatible = "broadcom,bcm5241" },
>
> And that's not the vendor prefix from vendor-prefixes.txt.

No, that dts containing this value predates vendor-prefixes.txt.

Previous to
commit 801a8ef54e8b ("of: phy: Only register a phy device for phys"), 
the form of the compatible string didn't matter for phys
>
>
>>  	{ .compatible = "marvell,88E1111", },
>>  	{ .compatible = "marvell,88e1116", },
>>  	{ .compatible = "marvell,88e1118", },
>>
>
>
