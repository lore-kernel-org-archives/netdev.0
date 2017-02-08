From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: vlan tunnel id info range fill size
 calc cleanups
Date: Wed, 08 Feb 2017 14:39:32 -0500 (EST)
Message-ID: <20170208.143932.1043944264336559559.davem@davemloft.net>
References: <1486512720-1071-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, colin.king@canonical.com,
        nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbdBHUQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:16:00 -0500
In-Reply-To: <1486512720-1071-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue,  7 Feb 2017 16:12:00 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This fixes a bug and cleans up tunnelid range size
> calculation code by using consistent variable names
> and checks in size calculation and fill functions.
> 
> tested for a few cases of vlan-vni range mappings:
> (output from patched iproute2):
> $bridge vlan showtunnel
> port     vid        tunid
> vxlan0   100-105    1000-1005
>          200        2000
>          210        2100
>          211-213    2100-2102
>          214        2104
>          216-217    2108-2109
>          219        2119
> 
> Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks Roopa.
