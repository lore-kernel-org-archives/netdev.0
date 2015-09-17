From: Jeremy Harris <jgh@redhat.com>
Subject: Re: [PATCH iproute2] man ip-link: Fix wording in VLAN reorder_hdr
 explanation
Date: Thu, 17 Sep 2015 09:59:01 +0100
Message-ID: <55FA80D5.8020204@redhat.com>
References: <1442422519-12679-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbbIQI7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 04:59:04 -0400
In-Reply-To: <1442422519-12679-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/15 17:55, Vadim Kochan wrote:
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  man/man8/ip-link.8.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 1896eb6..4928249 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -327,7 +327,7 @@ physical device (if this device does not support VLAN offloading), the similar
>  on the RX direction - by default the packet will be untagged before being
>  received by VLAN device. Reordering allows to accelerate tagging on egress and
>  to hide VLAN header on ingress so the packet looks like regular Ethernet packet,
> -at the same time it might be confusing while the packet sniffing as the VLAN header
> +at the same time it might be confusing for packet capture as the VLAN header
>  does not exist within the packet.
>  
>  VLAN offloading can be checked by
> 

Acked-by: Jeremy Harris <jgh@redhat.com>
