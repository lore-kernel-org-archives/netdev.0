From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/3] netconf: rename PROXY_ARP to NEIGH_PROXY
Date: Wed, 18 Dec 2013 12:06:45 -0500
Message-ID: <52B1D625.5060002@mojatatu.com>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:53774 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab3LRRGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 12:06:47 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so10219234ief.6
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 09:06:46 -0800 (PST)
In-Reply-To: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/13 01:35, Stephen Hemminger wrote:
> Use same field for both IPv4 (proxy_arp) and IPv6 (proxy_ndp)
> so fix it before API is set to be a common name
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> ---
>   include/uapi/linux/netconf.h |    2 +-
>   net/ipv4/devinet.c           |   10 +++++-----
>   2 files changed, 6 insertions(+), 6 deletions(-)
>
> --- a/include/uapi/linux/netconf.h	2013-12-17 22:30:00.000000000 -0800
> +++ b/include/uapi/linux/netconf.h	2013-12-17 22:31:07.973419694 -0800
> @@ -14,7 +14,7 @@ enum {
>   	NETCONFA_FORWARDING,
>   	NETCONFA_RP_FILTER,
>   	NETCONFA_MC_FORWARDING,
> -	NETCONFA_PROXY_ARP,
> +	NETCONFA_PROXY_NEIGH,
>   	__NETCONFA_MAX
>   };

Can you do this? ;-> Why not #define NETCONFA_PROXY_NEIGH to be 
NETCONFA_PROXY_ARP

cheers,
jamal
