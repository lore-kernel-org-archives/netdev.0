From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 01/15] i40e: fix null dereference
Date: Thu, 12 Dec 2013 18:30:16 +0400
Message-ID: <52A9C878.406@cogentembedded.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com> <1386852051-27907-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36214 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3LLOaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:30:15 -0500
Received: by mail-la0-f41.google.com with SMTP id eo20so377229lab.28
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 06:30:13 -0800 (PST)
In-Reply-To: <1386852051-27907-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 16:40, Jeff Kirsher wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

> If the vsi->tx_rings structure is NULL we don't want to panic.

> Change-Id: Ic694f043701738c434e8ebe0caf0673f4410dc10
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
>   1 file changed, 3 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index a6291e2..1ef311a 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -354,6 +354,9 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
>   	struct rtnl_link_stats64 *vsi_stats = i40e_get_vsi_stats_struct(vsi);
>   	int i;
>
> +	if (!vsi->tx_rings)
> +		return stats;
> +

    This looks like a fix, so should go to net.git, not net-next.git?

WBR, Sergei
