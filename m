From: Jie Deng <Jie.Deng1@synopsys.com>
Subject: Re: [PATCH net-next 1/2] net: phy: add extension of phy-mode for
 XLGMII
Date: Fri, 9 Dec 2016 13:19:07 +0800
Message-ID: <d42cbc77-1409-281a-161f-cf9c85443369@synopsys.com>
References: <cover.1481075763.git.jiedeng@synopsys.com>
 <6d4a65c5488364cdaec72eb22e742aa7e94dfebb.1481075763.git.jiedeng@synopsys.com>
 <30c8257d-9ad9-71bf-a969-77dbe37bd800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>,
        <lars.persson@axis.com>, <thomas.lendacky@amd.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Jie Deng <Jie.Deng1@synopsys.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <30c8257d-9ad9-71bf-a969-77dbe37bd800@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/12/9 6:15, Florian Fainelli wrote:
> On 12/06/2016 07:57 PM, Jie Deng wrote:
>> This patch adds phy-mode support for Synopsys XLGMAC
> The functional changes look good, but I would like to see some
> description of what the XL part stands for here.
>
> While you are modifying this, do you also mind submitting a Device Tree
> specification change:
>
> https://www.devicetree.org/specifications/
>
> Thanks!
Thank you for the information.

Currenlty, the XLGMAC is a new IP from Synopsys. We are using a PCI driver for
testing on FPGA platform.  Is it possible to add these changes first and submit
a device tree in the future?
>> Signed-off-by: Jie Deng <jiedeng@synopsys.com>
>> ---
>>  Documentation/devicetree/bindings/net/ethernet.txt | 1 +
>>  include/linux/phy.h                                | 3 +++
>>  2 files changed, 4 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
>> index 0515095..2378f00 100644
>> --- a/Documentation/devicetree/bindings/net/ethernet.txt
>> +++ b/Documentation/devicetree/bindings/net/ethernet.txt
>> @@ -28,6 +28,7 @@ The following properties are common to the Ethernet controllers:
>>    * "rtbi"
>>    * "smii"
>>    * "xgmii"
>> +  * "xlgmii"
>>    * "trgmii"
>>  - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
>>  - phy-handle: phandle, specifies a reference to a node representing a PHY
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index feb8a98..b52f9f8 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -79,6 +79,7 @@
>>  	PHY_INTERFACE_MODE_RTBI,
>>  	PHY_INTERFACE_MODE_SMII,
>>  	PHY_INTERFACE_MODE_XGMII,
>> +	PHY_INTERFACE_MODE_XLGMII,
>>  	PHY_INTERFACE_MODE_MOCA,
>>  	PHY_INTERFACE_MODE_QSGMII,
>>  	PHY_INTERFACE_MODE_TRGMII,
>> @@ -136,6 +137,8 @@ static inline const char *phy_modes(phy_interface_t interface)
>>  		return "smii";
>>  	case PHY_INTERFACE_MODE_XGMII:
>>  		return "xgmii";
>> +	case PHY_INTERFACE_MODE_XLGMII:
>> +		return "xlgmii";
>>  	case PHY_INTERFACE_MODE_MOCA:
>>  		return "moca";
>>  	case PHY_INTERFACE_MODE_QSGMII:
>>
>
