From: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 4/6] ARM: davinci: da850: add DT node for eth0.
Date: Fri, 8 Mar 2013 15:21:33 +0530
Message-ID: <5139B4A5.2050404@ti.com>
References: <1359380879-26306-1-git-send-email-prabhakar.lad@ti.com>
 <1359380879-26306-5-git-send-email-prabhakar.lad@ti.com>
 <510E51FF.8090005@ti.com>
 <CA+V-a8uT-iF_TdWQwvnc1PfcQ9z3WBuZ2MYS1X_u3wO0_p=T0w@mail.gmail.com>
 <510FF4C8.7000706@ti.com>
 <CA+V-a8tSjF0Zz53_v=d-hUdKK4ihK_aLceOYnmQFhhKLOx3y1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Lad,
 Prabhakar" <prabhakar.lad-l0cyMroinI0@public.gmane.org>, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <CA+V-a8tSjF0Zz53_v=d-hUdKK4ihK_aLceOYnmQFhhKLOx3y1g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 3/8/2013 3:15 PM, Prabhakar Lad wrote:
> Sekhar,
> 
> On Mon, Feb 4, 2013 at 11:20 PM, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org> wrote:
>> On 2/4/2013 10:37 AM, Prabhakar Lad wrote:
>>> Sekhar ,
>>>
>>> On Sun, Feb 3, 2013 at 5:33 PM, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org> wrote:
>>>> On 1/28/2013 7:17 PM, Prabhakar Lad wrote:
>>>>> From: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
>>>>>
>>>>> Add eth0 device tree node information and pinmux for mii to da850 by
>>>>> providing interrupt details and local mac address of eth0.
>>>>>
>>>>> Signed-off-by: Lad, Prabhakar <prabhakar.lad-l0cyMroinI0@public.gmane.org>
>>>>> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>>>>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
>>>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>>>>> Cc: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
>>>>> Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
>>>>> ---
>>>>>  arch/arm/boot/dts/da850-evm.dts |    5 +++++
>>>>>  arch/arm/boot/dts/da850.dtsi    |   35 +++++++++++++++++++++++++++++++++++
>>>>>  2 files changed, 40 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
>>>>> index a319491..19aa2b3 100644
>>>>> --- a/arch/arm/boot/dts/da850-evm.dts
>>>>> +++ b/arch/arm/boot/dts/da850-evm.dts
>>>>> @@ -30,6 +30,11 @@
>>>>>               mdio: davinci_mdio@1e24000 {
>>>>>                       status = "okay";
>>>>>               };
>>>>> +             eth0: emac@1e20000 {
>>>>> +                     status = "okay";
>>>>> +                     pinctrl-names = "default";
>>>>> +                     pinctrl-0 = <&mii_pins>;
>>>>> +             };
>>>>>       };
>>>>>       nand_cs3@62000000 {
>>>>>               status = "okay";
>>>>> diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
>>>>> index ba28f2d..76905f3 100644
>>>>> --- a/arch/arm/boot/dts/da850.dtsi
>>>>> +++ b/arch/arm/boot/dts/da850.dtsi
>>>>> @@ -56,6 +56,26 @@
>>>>>                                       0x30 0x01100000  0x0ff00000
>>>>>                               >;
>>>>>                       };
>>>>> +                     mii_pins: pinmux_mii_pins {
>>>>> +                             pinctrl-single,bits = <
>>>>> +                                     /*
>>>>> +                                      * MII_TXEN, MII_TXCLK, MII_COL
>>>>> +                                      * MII_TXD_3, MII_TXD_2, MII_TXD_1
>>>>> +                                      * MII_TXD_0
>>>>> +                                      */
>>>>> +                                     0x8 0x88888880 0xfffffff0
>>>>> +                                     /*
>>>>> +                                      * MII_RXER, MII_CRS, MII_RXCLK
>>>>> +                                      * MII_RXDV, MII_RXD_3, MII_RXD_2
>>>>> +                                      * MII_RXD_1, MII_RXD_0
>>>>> +                                      */
>>>>> +                                     0xc 0x88888888 0xffffffff
>>>>> +                                     /* MDIO_CLK, MDIO_D */
>>>>
>>>> You call this mii_pins, but include mdio pins in there as well. Can you
>>>> separate them out? Then some board which uses rmii can simply reuse the
>>>> entry.
>>>>
>>> Ok makes sense.
>>>
>>>>> +                                     0x10 0x00222288 0x00ffffff
>>>>> +                                     /* GPIO2_6 */
>>>>> +                                     0x18 0x00000080 0x000000f0
>>>>
>>>> This is SoC specific pin list. Such board specific pins should not make
>>>> it here.
>>>>
>>> Ok, so this should be set up using GPIO API's ?
>>
>> Yes, the pins ultimately will be controlled by gpiolib APIs, but the
>> pins should be defined under the eth node in .dts
>>
> You mean '0x18 0x00000080 0x000000f0'  still needs to defined in eth0 node ?
> Can you elaborate and give some pointers.

Since the GPIO usage for ethernet is board specific, it cannot be in
.dtsi which is SoC generic. I am suggesting do in the .dts file which is
board specific.

Thanks,
Sekhar
