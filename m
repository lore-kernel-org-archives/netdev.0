From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: Re: [PATCH net-next 0/2] net: stmmac: Support DWMAC5 and TSN
Date: Fri, 27 Oct 2017 09:46:12 +0100
Message-ID: <9af4831a-e93e-16cc-4b9c-82c3e0c79fb5@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <9f37e884-be5e-b20f-1f5e-ddfd17d20c54@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:51744 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752305AbdJ0IqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 04:46:18 -0400
In-Reply-To: <9f37e884-be5e-b20f-1f5e-ddfd17d20c54@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesus,

On 26-10-2017 17:28, Jesus Sanchez-Palencia wrote:
> Hi Jose,
>
>
> On 10/25/2017 07:02 AM, Jose Abreu wrote:
>> Hi,
>>
>> This adds support for a new IP version (5) of dwmac and for
>> TSN features as defined by IEEE802.1Qbv-2015 and IEEE802.1Qbu.
>
> Just out of curiosity, are you aware of any NICs that are publicly
> available which use this IP version?

The IP was just released and these are fresh new features, you
can find more info here [1]. We expect manufacturers to start
adopting this IP release soon.

Best Regards,
Jose Miguel Abreu

[1] https://www.synopsys.com/dw/ipdir.php?ds=dwc_ether_qos

>
> Thanks,
> Jesus
>
>
>> Please review.
>>
>> Best regards,
>> Jose Miguel Abreu
>>
>> Jose Abreu (2):
>>   net: stmmac: Add support for DWMAC5 with TSN features
>>   bindings: net: stmmac: Add documentation for TSN parameters
>>
>>  Documentation/devicetree/bindings/net/stmmac.txt   | 20 +++++
>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
>>  drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +
>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++-
>>  drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c   | 99 ++++++++++++++++++++++
>>  drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h   | 57 +++++++++++++
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  4 +
>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 57 ++++++++++++-
>>  include/linux/stmmac.h                             | 11 +++
>>  9 files changed, 288 insertions(+), 3 deletions(-)
>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h
>>
