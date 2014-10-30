From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/5] stmmac: pci: various cleanups and fixes
Date: Thu, 30 Oct 2014 09:13:32 +0100
Message-ID: <5451F32C.8060403@st.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<netdev@vger.kernel.org>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:53701 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750914AbaJ3INt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 04:13:49 -0400
In-Reply-To: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2014 6:35 PM, Andy Shevchenko wrote:
> There are few cleanups and fixes regarding to stmmac PCI driver.
> This has been tested on Intel Galileo board with 3.18-rc1 kernel.

Hello Andy,

for your next version I think that the patches should be for net-next
tree.
Maybe the following for net.git: "stmmac: pci: set default filter bins"

I kindly ask you to detail fix and cleanup.

peppe

>
> Andy Shevchenko (5):
>    stmmac: pci: convert to use dev_pm_ops
>    stmmac: pci: use managed resources
>    stmmac: pci: convert to use dev_* macros
>    stmmac: pci: set default filter bins
>    stmmac: pci: remove FSF address
>
>   drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 92 ++++++++----------------
>   1 file changed, 30 insertions(+), 62 deletions(-)
>
