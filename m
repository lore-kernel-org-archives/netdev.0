From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH ethtool] ethtool: Report Backplane as supported port
Date: Fri, 21 Feb 2014 11:40:03 +0100
Message-ID: <53072D03.1030308@redhat.com>
References: <1392918536-20444-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bwh@kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754813AbaBUKkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 05:40:12 -0500
In-Reply-To: <1392918536-20444-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave & Ben,
I see the patch is in 'not applicable' state in patchwork. The patch is 
for ethtool userspace. I though the netdev mailing list is also for 
ethtool userspace or did I used bad subject prefix?

Thanks,
Ivan

On 02/20/2014 06:48 PM, Ivan Vecera wrote:
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>   ethtool.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/ethtool.c b/ethtool.c
> index 315d00f..acb4397 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -496,6 +496,8 @@ static void dump_supported(struct ethtool_cmd *ep)
>   		fprintf(stdout, "MII ");
>   	if (mask & SUPPORTED_FIBRE)
>   		fprintf(stdout, "FIBRE ");
> +	if (mask & SUPPORTED_Backplane)
> +		fprintf(stdout, "Backplane ");
>   	fprintf(stdout, "]\n");
>
>   	dump_link_caps("Supported", "Supports", mask, 0);
>
