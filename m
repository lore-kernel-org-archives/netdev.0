From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH v4 3/5] ARM: dts: AM33XX: Add pinmux configuration
 for CPSW to beaglebone
Date: Thu, 6 Jun 2013 13:51:46 +0530
Message-ID: <51B0469A.4080501@ti.com>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
 <1370452099-24026-4-git-send-email-mugunthanvnm@ti.com>
 <51B034ED.7040603@epfl.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 benoit.cousson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <florian.vaussard-p8DiymsW2f8@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <51B034ED.7040603-p8DiymsW2f8@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 6/6/2013 12:36 PM, Florian Vaussard wrote:
> Hello,
>
> On 06/05/2013 07:08 PM, Mugunthan V N wrote:
>> Add pinmux configurations for MII based CPSW ethernet to am335x-bone.
>> In this patch, only single named mode/state is added and these pins
>> are configured during pinctrl driver initialization.
>>
>> Default mode is nothing but the values required for the module during
>> active state. With this configurations module is functional as
>> expected.
>>
>> Todo:
>> - if an idle state is available for pins, add support for it.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>> ---
>>   arch/arm/boot/dts/am335x-bone.dts |   38 
>> +++++++++++++++++++++++++++++++++++++
>>   1 file changed, 38 insertions(+)
>>
>> diff --git a/arch/arm/boot/dts/am335x-bone.dts 
>> b/arch/arm/boot/dts/am335x-bone.dts
>> index 4b5a8e0..008a13b 100644
>> --- a/arch/arm/boot/dts/am335x-bone.dts
>> +++ b/arch/arm/boot/dts/am335x-bone.dts
>> @@ -36,6 +36,33 @@
>>                   0x60 0x17    /* gpmc_a8.gpio1_24, OUTPUT_PULLUP | 
>> MODE7 */
>>               >;
>>           };
>> +
>> +        cpsw_default: cpsw_default {
>> +            pinctrl-single,pins = <
>> +                /* Slave 1 */
>> +                0x110 0x20    /* mii1_rxerr.mii1_rxerr, MODE0 | 
>> INPUT */
>
> Here I guess that the comment should be INPUT_PULLDOWN, instead of INPUT.
Good catch, I will modify this and submit next version today.
>
>> +                0x114 0x0    /* mii1_txen.mii1_txen, MODE0 | OUTPUT */
>
> As bit PULLUDENABLE is 0, the pulldown is enabled according to the 
> TRM, right?
> Is this a desirable behaviour, as it will consume power when 
> outputting a high level?
This is the desirable behavior.
> And consequently, the comment should probably be OUTPUT_PULLDOWN, no?
Will update this in next version of patch series.

Regards
Mugunthan V N
