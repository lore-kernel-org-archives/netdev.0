From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [PATCH net-next 0/2] net: stmmac: Support DWMAC5 and TSN
Date: Thu, 26 Oct 2017 09:28:22 -0700
Message-ID: <9f37e884-be5e-b20f-1f5e-ddfd17d20c54@intel.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jose Abreu <Jose.Abreu@synopsys.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57243 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932291AbdJZQf4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:35:56 -0400
In-Reply-To: <cover.1508938927.git.joabreu@synopsys.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jose,


On 10/25/2017 07:02 AM, Jose Abreu wrote:
> Hi,
> 
> This adds support for a new IP version (5) of dwmac and for
> TSN features as defined by IEEE802.1Qbv-2015 and IEEE802.1Qbu.


Just out of curiosity, are you aware of any NICs that are publicly
available which use this IP version?

Thanks,
Jesus


> 
> Please review.
> 
> Best regards,
> Jose Miguel Abreu
> 
> Jose Abreu (2):
>   net: stmmac: Add support for DWMAC5 with TSN features
>   bindings: net: stmmac: Add documentation for TSN parameters
> 
>  Documentation/devicetree/bindings/net/stmmac.txt   | 20 +++++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |  2 +-
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  4 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c   | 99 ++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h   | 57 +++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  4 +
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 57 ++++++++++++-
>  include/linux/stmmac.h                             | 11 +++
>  9 files changed, 288 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac5_tsn.h
> 
