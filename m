From: Nathan Williams <nathan@traverse.com.au>
Subject: Re: [PATCH 1/4] [atm] fixed faulty check
Date: Fri, 31 Jul 2009 10:22:48 +1000
Message-ID: <4A723958.3030807@traverse.com.au>
References: <1248949491-20796-1-git-send-email-sgayda2@uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil,
	David.Woodhouse@intel.com, netdev@vger.kernel.org
To: Stoyan Gaydarov <sgayda2@uiuc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail05.adl2.internode.on.net ([203.16.214.145]:42187 "EHLO
	ipmail05.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbZGaAWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 20:22:48 -0400
In-Reply-To: <1248949491-20796-1-git-send-email-sgayda2@uiuc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stoyan Gaydarov wrote:
> This patche fixes a spelling error that has resulted from copy and pasting. The location of the error was found using a semantic patch but the semantic patch was not trying to find these errors. After looking things over it seemed logical that this change was needed. Please review it and then include the patch if it is in fact the correct change.
> 
> Signed-off-by: Stoyan Gaydarov <sgayda2@uiuc.edu>
> ---
>  drivers/atm/solos-pci.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
> index 9359613..307321b 100644
> --- a/drivers/atm/solos-pci.c
> +++ b/drivers/atm/solos-pci.c
> @@ -372,7 +372,7 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
>  	}
>  
>  	snr = next_string(skb);
> -	if (!str)
> +	if (!snr)
>  		return -EIO;
>  	attn = next_string(skb);
>  	if (!attn)

Thanks Stoyan.  Julia Lawall found this error a few days ago, which has been applied to net-next-2.6.
