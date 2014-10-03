From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next] fm10k: Add CONFIG_FM10K_VXLAN configuration option
Date: Fri, 03 Oct 2014 14:40:07 -0700
Message-ID: <542F17B7.80706@intel.com>
References: <1412370352-17680-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58507 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584AbaJCVkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 17:40:10 -0400
In-Reply-To: <1412370352-17680-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 02:05 PM, Andy Zhou wrote:
> Compiling with CONFIG_FM10K=y and VXLAN=m resulting in linking error:
> 
>    drivers/built-in.o: In function `fm10k_open':
>    (.text+0x1f9d7a): undefined reference to `vxlan_get_rx_port'
>    make: *** [vmlinux] Error 1
> 
> The fix follows the same strategy as I40E.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  drivers/net/ethernet/intel/Kconfig              | 11 +++++++++++
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |  6 +++---
>  2 files changed, 14 insertions(+), 3 deletions(-)

Looks good to me.  Thanks for resolving this.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
