From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/3] bonding: add option lp_interval for loading
 module
Date: Fri, 20 Dec 2013 17:42:43 +0400
Message-ID: <52B44953.30703@cogentembedded.com>
References: <52B3D15F.3080703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:62747 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352Ab3LTNmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 08:42:35 -0500
Received: by mail-la0-f52.google.com with SMTP id y1so1088927lam.39
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 05:42:34 -0800 (PST)
In-Reply-To: <52B3D15F.3080703@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-12-2013 9:10, Ding Tianhong wrote:

> The bond driver could set the lp_interval when loading module.

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/bonding/bond_main.c | 15 +++++++++++++--
>   1 file changed, 13 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index c0456cc..368f7e4 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
[...]
> @@ -4271,6 +4276,12 @@ static int bond_check_params(struct bond_params *params)
>   		fail_over_mac_value = BOND_FOM_NONE;
>   	}
>
> +	if (lp_interval == 0) {
> +		pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
> +			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);

    The continuation line should be aligned under ", according to the 
networking coding style.

WBR, Sergei
