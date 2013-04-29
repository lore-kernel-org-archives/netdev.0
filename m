From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH net 0/3] Bug fixes for cxgb4 and cxgb4vf
Date: Mon, 29 Apr 2013 20:19:28 +0530
Message-ID: <517E8878.4080900@chelsio.com>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vipul Pandya <vipul@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Abhishek Agrawal <abhishek@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	SWise OGC <swise@opengridcomputing.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12200 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490Ab3D2Ote (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:49:34 -0400
In-Reply-To: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 29-04-2013 19:34, Vipul Pandya wrote:
> Hi All,
> 
> This patch series does the following:
> 1. Passes correct PF number during initialization of pci_device_id structure
> 2. Adds code in cxgb4 and cxgb4vf driver to handle CPL_SGE_EGR_UPDATE message
>    encapsulated in a CPL_FW4_MSG.
> 
> We would like to request this patch series to get merged via David Miller's
> 'net' tree.
> 
> Thanks,
> Vipul
> 
> Vipul Pandya (3):
>   cxgb4: Fix pci_device_id structure initialization with correct PF
>     number
>   cxgb4: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG
>   cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG
> 
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 107 +++++++++++++--------
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  11 +++
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  38 +++++++-
>  .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  25 +++++
>  4 files changed, 140 insertions(+), 41 deletions(-)
> 

Hi David Miller,

I have forgotten to check if 'net' and 'net-next' tree are in sync or
not. I am sorry for that. This patch series is built against net-next
tree. Since these are bug fixes we wanted to merge it via 'net' tree.
However now I see that required patches are missing in 'net' tree. To be
able to successfully apply this patch series in 'net' tree we need
patches from commit 47ce9c482 (cxgb4: Allow for backward compatibility
with new VPD scheme.) into 'net' tree. If it is not possible to apply
those patches into 'net' tree then please apply this patch series
against 'net-next'. Please let me know if I have to resend the series.

Thanks,
Vipul
