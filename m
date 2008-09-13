From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ehea: fix phyp debugging typo
Date: Sat, 13 Sep 2008 15:12:35 -0400
Message-ID: <48CC10A3.6020608@garzik.org>
References: <1221140080-9853-1-git-send-email-sebastien.dugue@bull.net> <1221140080-9853-2-git-send-email-sebastien.dugue@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, themann@de.ibm.com, tklein@de.ibm.com,
	raisch@de.ibm.com, jean-pierre.dion@bull.net,
	gilles.carry@ext.bull.net, tinytim@us.ibm.com
To: Sebastien Dugue <sebastien.dugue@bull.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753304AbYIMTM5@vger.kernel.org>
In-Reply-To: <1221140080-9853-2-git-send-email-sebastien.dugue@bull.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastien Dugue wrote:
>   Fix typo in ehea_h_query_ehea() which prevents building when DEBUG is on.
> 
> Signed-off-by: Sebastien Dugue <sebastien.dugue@bull.net>
> ---
>  drivers/net/ehea/ehea_phyp.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
> index 156eb63..2a33a61 100644
> --- a/drivers/net/ehea/ehea_phyp.c
> +++ b/drivers/net/ehea/ehea_phyp.c
> @@ -535,7 +535,7 @@ u64 ehea_h_query_ehea(const u64 adapter_handle, void *cb_addr)
>  				       cb_logaddr,		/* R5 */
>  				       0, 0, 0, 0, 0);		/* R6-R10 */
>  #ifdef DEBUG
> -	ehea_dmp(cb_addr, sizeof(struct hcp_query_ehea), "hcp_query_ehea");
> +	ehea_dump(cb_addr, sizeof(struct hcp_query_ehea), "hcp_query_ehea");
>  #endif
>  	return hret;

applied
