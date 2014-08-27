From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/4] net: stmmac: Enable Intel Quark SoC X1000 Ethernet
 support
Date: Wed, 27 Aug 2014 14:52:52 +0200
Message-ID: <53FDD4A4.5020603@st.com>
References: <cover.1409123378.git.hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Rayagond K <rayagond@vayavyalabs.com>
To: Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1409123378.git.hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/2014 12:32 PM, Kweh Hock Leong wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>
> Hi,
>
> Intel Quark X1000 SoC has 2 Ethernet controllers integrated on chip and they are
> PCI devices. We adopted the stmmac_pci driver and added on code to support Intel
> Quark SoC X1000 by creating the patchset below. The patchset has been built and
> tested on Galileo board and found to be working as expected.
>
> We believe that the changes are transparent to other non Intel Quark platform.
> Please help to review the code change and feedback if there is any concern.

hello and thx for these patches that at first glance look ok to me.
Just some minor remark, in the stmmac I try to align the function 
parameters with the open parenthesis (devm_kzalloc in your case in not 
aligned).
Added on copy also Rayagond he tested PCI. I cannot do any test because 
I have no PCI cards.

peppe

>
> Thank you very much.
>
> Kweh, Hock Leong (4):
>    net: stmmac: enhance to support multiple device instances
>    net: stmmac: better code manageability with platform data struct
>    net: stmmac: add support for Intel Quark X1000
>    net: stmmac: add MSI support for Intel Quark X1000
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |  195 +++++++++++++++++++---
>   1 file changed, 172 insertions(+), 23 deletions(-)
>
