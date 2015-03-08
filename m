From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 5/6] mpls: Fix the openvswitch select of
 NET_MPLS_GSO
Date: Sun, 8 Mar 2015 18:09:51 +0900
Message-ID: <20150308090951.GA17311@verge.net.au>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
 <871tl04fag.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38067 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbCHJJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 05:09:55 -0400
Content-Disposition: inline
In-Reply-To: <871tl04fag.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 07, 2015 at 04:24:23PM -0600, Eric W. Biederman wrote:
> 
> Fix the OPENVSWITCH Kconfig option and old Kconfigs by having
> OPENVSWITCH select both NET_MPLS_GSO and MPLSO.
> 
> A Kbuild test robot reported that when NET_MPLS_GSO is selected by
> OPENVSWITCH the generated .config is broken because MPLS is not
> selected.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Fixes: cec9166ca4e mpls: Refactor how the mpls module is built
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  net/openvswitch/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
> index b7d818c59423..ed6b0f8dd1bb 100644
> --- a/net/openvswitch/Kconfig
> +++ b/net/openvswitch/Kconfig
> @@ -6,6 +6,7 @@ config OPENVSWITCH
>  	tristate "Open vSwitch"
>  	depends on INET
>  	select LIBCRC32C
> +	select MPLS
>  	select NET_MPLS_GSO
>  	---help---
>  	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
> -- 
> 2.2.1
> 
