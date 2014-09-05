From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: limit primary_reselect to modes that
 use primary only
Date: Fri, 05 Sep 2014 14:17:36 +0200
Message-ID: <5409A9E0.8050502@redhat.com>
References: <1409919210-28944-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbaIEMRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 08:17:42 -0400
In-Reply-To: <1409919210-28944-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/14 14:13, Nikolay Aleksandrov wrote:
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
>   drivers/net/bonding/bond_options.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
> index d8dc17faa6b4..591c1fbb7c8d 100644
> --- a/drivers/net/bonding/bond_options.c
> +++ b/drivers/net/bonding/bond_options.c
> @@ -316,6 +316,9 @@ static const struct bond_option bond_opts[] = {
>   		.id = BOND_OPT_PRIMARY_RESELECT,
>   		.name = "primary_reselect",
>   		.desc = "Reselect primary slave once it comes up",
> +		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP) |
> +						BIT(BOND_MODE_TLB) |
> +						BIT(BOND_MODE_ALB)),
>   		.values = bond_primary_reselect_tbl,
>   		.set = bond_option_primary_reselect_set
>   	},
>

Actually, self-nak as this adds option dependency.
Sorry for the noise

Nik
