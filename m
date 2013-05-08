From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] net/mlx4_core: Add missing report on VST and
 spoof-checking dev caps
Date: Wed, 08 May 2013 19:58:30 +0400
Message-ID: <518A7626.5060409@cogentembedded.com>
References: <1368016228-19783-1-git-send-email-ogerlitz@mellanox.com> <1368016228-19783-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, amirv@mellanox.com,
	ronye@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:48990 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018Ab3EHP63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 11:58:29 -0400
Received: by mail-la0-f46.google.com with SMTP id fk20so1931269lab.19
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 08:58:28 -0700 (PDT)
In-Reply-To: <1368016228-19783-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08-05-2013 16:30, Or Gerlitz wrote:

> Commits e6b6a23 "net/mlx4: Add VF MAC spoof checking support" and
> 3f7fb021 "net/mlx4: Add set VF default vlan ID and priority support"
> missed reporting in the device capabilities dump when these features
> are actually supported. Also two too noisy debug messages which produce
> message on every QP opened by a VF, were left in the code, fix that.

> Signed-off-by: Rony Efraim <ronye@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/fw.c            |    4 +++-
>   .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    9 ---------
>   2 files changed, 3 insertions(+), 10 deletions(-)

> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
> index b147bdd..5444a1a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/fw.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
> @@ -131,7 +131,9 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
>   		[2] = "RSS XOR Hash Function support",
>   		[3] = "Device manage flow steering support",
>   		[4] = "Automatic MAC reassignment support",
> -		[5] = "Time stamping support"
> +		[5] = "Time stamping support",
> +		[6] = "VST (control vlan insertion/stripping) support",
> +		[7] = "FSM (MAC unti-spoofing) support"

     Perhaps "anti-"?

WBR, Sergei
