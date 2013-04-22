From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V2 1/5] net/mlx4_core: Add timestamping device
 capability
Date: Mon, 22 Apr 2013 21:10:55 +0400
Message-ID: <51756F1F.8030903@cogentembedded.com>
References: <1366631767-16493-1-git-send-email-amirv@mellanox.com> <1366631767-16493-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:64018 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3DVRLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 13:11:44 -0400
Received: by mail-lb0-f179.google.com with SMTP id t1so5893564lbd.10
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 10:11:43 -0700 (PDT)
In-Reply-To: <1366631767-16493-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/22/2013 03:56 PM, Amir Vadai wrote:

> From: Eugenia Emantayev <eugenia@mellanox.com>
>
> Add new device capability for timestamping support and query FW to retrieve it.
>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/fw.c |    7 ++++++-
>   include/linux/mlx4/device.h             |    3 ++-
>   2 files changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
> index ab470d9..8f394be 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/fw.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
> @@ -130,7 +130,8 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
>   		[1] = "RSS Toeplitz Hash Function support",
>   		[2] = "RSS XOR Hash Function support",
>   		[3] = "Device manage flow steering support",
> -		[4] = "Automatic mac reassignment support"
> +		[4] = "Automatic mac reassignment support",

    "MAC" perhaps? Although you're only adding a comma...

WBR, Sergei
