From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Wed, 11 Jan 2017 10:35:40 +0000
Message-ID: <df4597b0-019d-07e1-e4f0-37d4920125d9@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <40521f32-436d-b31d-92a4-4cff97f3411d@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <CARLOS.PALMINHA@synopsys.com>
To: Jie Deng <Jie.Deng1@synopsys.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:35672 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760755AbdAKKgA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 05:36:00 -0500
In-Reply-To: <40521f32-436d-b31d-92a4-4cff97f3411d@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jie,

Às 4:00 AM de 1/11/2017, Jie Deng escreveu:
> Hi Joao,
> 
> 
> On 2017/1/10 22:52, Joao Pinto wrote:
>> This patch renames stmicro/stmmac to synopsys/ since it is a standard
>> ethernet software package regarding synopsys ethernet controllers, supporting
>> the majority of Synopsys Ethernet IPs. The config IDs remain the same, for
>> retro-compatibility, only the description was changed.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> ---
>> changes v1->v2:
>> - nothing changed. Just to keep up with patch set version
>>
>> @@ -1,5 +1,5 @@
>>  config STMMAC_ETH
>> -	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
>> +	tristate "Synopsys Ethernet drivers"
>>  	depends on HAS_IOMEM && HAS_DMA
>>  	select MII
>>  	select PHYLIB
>> @@ -14,7 +14,7 @@ config STMMAC_ETH
>>  if STMMAC_ETH
>>  
> "Synopsys Ethernet drivers" is too generic. The name should reflect the
> controller. This driver is for Synopsys GMAC 10M/100M/1G IPs. We will submit a
> driver for the new 25G/40G/50G/100G XLGMAC IP in the future.

As you know Synopsys is an IP vendor that as a wide range of IPs related to
Ethernet. stmmac is a driver that was well built and well maintained and
supports most of those Ethernet IPs, so it has the potential to be the official
Synopsys Ethernet driver suite in the future.

Let's make baby steps. For now stmmac supports 10M/100M/1G and also QoS which is
a separated IP and the different IP cores are selected by device tree.

In the future it would be usefull to be selectable by Kconfig options, making it
more clear to the kernel user. For example:

Synopsys Ethernet drivers
  eQoS Core
  10M Core
  100M Core
  1G Core
  25G Core
  ....

The XLGMAC will be great for our users and I will be 100% available to help you
with it.

Thanks,
Joao

>>  config STMMAC_PLATFORM
>> -	tristate "STMMAC Platform bus support"
>> +	tristate "Platform bus support"
>>  	depends on STMMAC_ETH
>>  	select MFD_SYSCON
>>  	default y
>> @@ -149,13 +149,13 @@ config DWMAC_SUNXI
>>  endif
>>  
>>  config STMMAC_PCI
>> -	tristate "STMMAC PCI bus support"
>> +	tristate "PCI bus support"
>>  	depends on STMMAC_ETH && PCI
>>  	---help---
>>  	  This is to select the Synopsys DWMAC available on PCI devices,
>>  	  if you have a controller with this interface, say Y or M here.
>>  
>> -	  This PCI support is tested on XLINX XC2V3000 FF1152AMT0221
>> +	  This PCI support was tested on XLINX XC2V3000 FF1152AMT0221
>>  	  D1215994A VIRTEX FPGA board.
> The name is also too generic. Please try to reflect the controller.
> 
> Thanks,
> Jie
> 
