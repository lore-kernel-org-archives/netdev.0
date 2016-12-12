From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Re: stmmac driver...
Date: Mon, 12 Dec 2016 13:14:47 +0100
Message-ID: <62b28c2c-68f3-d259-af68-ec18ae0ffcdf@axis.com>
References: <20161207.130654.1484281922991494182.davem@davemloft.net>
 <e8370557-b11a-0fe6-f87f-3af2e5990f27@st.com>
 <20161208.102552.714315690167693892.davem@davemloft.net>
 <59b37368-8670-659a-c257-034f73a83136@synopsys.com>
 <CAD5ja62JQzjkM2VD7N+D0Vz3tOM7y9dZ43Fd_+ARz_OzLTOF-w@mail.gmail.com>
 <f64fde7c-9fe5-7ed9-8d01-23702e64f8aa@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <alexandre.torgue@st.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <Joao.Pinto@synopsys.com>
To: Jie Deng <Jie.Deng1@synopsys.com>,
        Niklas Cassel <nks.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:46432 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750696AbcLLMOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 07:14:52 -0500
In-Reply-To: <f64fde7c-9fe5-7ed9-8d01-23702e64f8aa@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend with netdev included)

On 12/09/2016 05:29 PM, Jie Deng wrote:
>
> On 2016/12/9 18:50, Niklas Cassel wrote:
>> Hello Jie Deng
>>
>>
>> In your cover letter you wrote
>>
>> dwc-eth-xxx.x
>>   The DWC ethernet core layer (DWC ECL). This layer contains codes
>> can be shared by different DWC series ethernet cores
>>
>> Does this mean that code in dwc-eth-xxx.x is common to all
>> the different Synopsys IPs, GMAC, XGMAC and XLGMAC ?
>>
>>
>> Regards,
>> Niklas
> Yeah,  these codes may be reused in the future (due to HW similarities) but it
> would require a lot of refactoring. For the moment I will focus on the driver
> only for XLGMAC.

Ok, thank you for the clarification.

>
> XLGMAC is Synopsys "Enterprise MAC" controller (the product is already public):
> https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_enterprise_mac
>
> What do you think following strategy:
> - GMAC (QoS): discard drivers/net/ethernet/synopsys/dwc_eth_qos.c and keep
> development under drivers/net/ethernet/stmicro/stmmac/
> - XGMAC: keep development under drivers/net/ethernet/amd/xgbe/
> - XLGMAC: do development under drivers/net/ethernet/synopsys/

I don't have an opinion regarding XLGMAC.

For GMAC, I think it's a good idea that everybody focuses on the same driver (stmmac).
The same thing applies to XGMAC, amd-xgbe and sxgbe, however there I don't know
of any consolidation efforts.

>
> Thanks,
> Jie
>
>> On Fri, Dec 9, 2016 at 11:05 AM, Jie Deng <Jie.Deng1@synopsys.com> wrote:
>>> On 2016/12/8 23:25, David Miller wrote:
>>>> From: Alexandre Torgue <alexandre.torgue@st.com>
>>>> Date: Thu, 8 Dec 2016 14:55:04 +0100
>>>>
>>>>> Maybe I forget some series. Do you have others in mind ?
>>>> Please see the thread titled:
>>>>
>>>> "net: ethernet: Initial driver for Synopsys DWC XLGMAC"
>>>>
>>>> which seems to be discussing consolidation of various drivers
>>>> for the same IP core, of which stmmac is one.
>>>>
>>>> I personally am against any change of the driver name and
>>>> things like this, and wish the people doing that work would
>>>> simply contribute to making whatever changes they need directly
>>>> to the stmmac driver.
>>>>
>>>> You really need to voice your opinion when major changes are being
>>>> proposed for the driver you maintain.
>>>>
>>> Hi David and Alex,
>>>
>>> XLGMAC is not a version of GMAC. Synopsys has several IPs and each IP has
>>> several versions.
>>>
>>> GMAC(QoS): 3.5, 3.7, 4.0, 4.10, 4.20...
>>> XGMAC: 1.00, 1.10, 1.20, 2.00, 2.10, 2.11...
>>> XLGMAC (Synopsys DesignWare Core Enterprise Ethernet): this is a new IP.
>>>
>>> Regards,
>>> Jie
>>>
>
