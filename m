From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Wed, 11 Jan 2017 21:05:10 -0800
Message-ID: <43126ae9-dc03-a323-2376-b6d72ad5ebc5@gmail.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <40521f32-436d-b31d-92a4-4cff97f3411d@synopsys.com>
 <df4597b0-019d-07e1-e4f0-37d4920125d9@synopsys.com>
 <03c4bef3-de38-0e51-e20d-2c9fc4bb6f8d@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: lars.persson@axis.com, niklass@axis.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        CARLOS.PALMINHA@synopsys.com
To: Jie Deng <Jie.Deng1@synopsys.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35378 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdALFFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 00:05:14 -0500
Received: by mail-oi0-f67.google.com with SMTP id x84so1330611oix.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 21:05:13 -0800 (PST)
In-Reply-To: <03c4bef3-de38-0e51-e20d-2c9fc4bb6f8d@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/11/2017 07:44 PM, Jie Deng wrote:
> Hi Joao,
> 
> On 2017/1/11 18:35, Joao Pinto wrote:
>> Hi Jie,
>>
>> Às 4:00 AM de 1/11/2017, Jie Deng escreveu:
>>> Hi Joao,
>>>
>>>
>>> On 2017/1/10 22:52, Joao Pinto wrote:
>>>> This patch renames stmicro/stmmac to synopsys/ since it is a standard
>>>> ethernet software package regarding synopsys ethernet controllers, supporting
>>>> the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
>>>> retro-compatibility, only the description was changed.
>>>>
>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>> ---
>>>> changes v1->v2:
>>>> - nothing changed. Just to keep up with patch set version
>>>>
>>>> @@ -1,5 +1,5 @@
>>>>  config STMMAC_ETH
>>>> -	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
>>>> +	tristate "Synopsys Ethernet drivers"
>>>>  	depends on HAS_IOMEM && HAS_DMA
>>>>  	select MII
>>>>  	select PHYLIB
>>>> @@ -14,7 +14,7 @@ config STMMAC_ETH
>>>>  if STMMAC_ETH
>>>>  
>>> "Synopsys Ethernet drivers" is too generic. The name should reflect the
>>> controller. This driver is for Synopsys GMAC 10M/100M/1G IPs. We will submit a
>>> driver for the new 25G/40G/50G/100G XLGMAC IP in the future.
>> As you know Synopsys is an IP vendor that as a wide range of IPs related to
>> Ethernet. stmmac is a driver that was well built and well maintained and
>> supports most of those Ethernet IPs, so it has the potential to be the official
>> Synopsys Ethernet driver suite in the future.
>>
>> Let's make baby steps. For now stmmac supports 10M/100M/1G and also QoS which is
>> a separated IP and the different IP cores are selected by device tree.
>>
>> In the future it would be usefull to be selectable by Kconfig options, making it
>> more clear to the kernel user. For example:
>>
>> Synopsys Ethernet drivers
>>   eQoS Core
>>   10M Core
>>   100M Core
>>   1G Core
>>   25G Core
>>   ....
>>
>> The XLGMAC will be great for our users and I will be 100% available to help you
>> with it.
>>
>> Thanks,
>> Joao
>>
> Currently, Synopsys has three series IPs cores. They are
>     1. 10M/100M/1G   (GMAC, QoS)
>     2. 1G/2.5G/5G/10G (XGMAC)
>     3. 10G/25G/40G/50G/100G (XLGMAC)
> More info: https://www.synopsys.com/designware-ip/interface-ip/ethernet.html
>  
> You have successfully merged  dwc_eth_qos.c into stmmac. stmmac now fully
> supports the 10M/100M/1G series IPs. Personally, I do support Florian's
> suggestion not to rename stmmac.
> considering to avoid  future confusion and make easy maintenance, Following is
> my suggestions
>    1. not to do any rename
>    2. keep all 10M/100M/1G IPs (GMAC, QoS) development in stmmac.
>    3. keep all 1G/2.5G/5G/10G IP (XGMAC) development in amd-xgbe.
>    4. submit a new driver under synopsys/ for the new 10G/25G/40G/50G/100G
> (XLGMAC) IP.
> 
> Welcome opinions from others.

Seems like a reasonable plan to me. If it helps avoid confusion, you
could always add an entry under Documentation/networking/ which
describes the history of the various drivers, and the reasons why they
are not consolidated under a synopsys directory.

Cheers
-- 
Florian
