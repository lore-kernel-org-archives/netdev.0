From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3 04/12] net: dsa: retain a per-port device_node
 pointer
Date: Sun, 24 Aug 2014 16:32:23 -0700
Message-ID: <53FA7607.1080906@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33313 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbaHXXc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 19:32:27 -0400
Received: by mail-pd0-f172.google.com with SMTP id y13so19233809pdi.3
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 16:32:26 -0700 (PDT)
In-Reply-To: <1408905869-10471-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2014 11:44 AM, Florian Fainelli wrote:
> We will later use the per-port device_node pointer to fetch a bunch of
> port-specific properties.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  include/net/dsa.h | 1 +
>  net/dsa/dsa.c     | 2 ++
>  net/dsa/slave.c   | 1 +
>  3 files changed, 4 insertions(+)
>
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 91d5ba435ab6..66bb036831fd 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -41,6 +41,7 @@ struct dsa_chip_data {
>  	 * or any other string to indicate this is a physical port.
>  	 */
>  	char		*port_names[DSA_MAX_PORTS];
> +	struct device_node *port_dn[DSA_MAX_PORTS];
>  
>  	/*
>  	 * An array (with nr_chips elements) of which element [a]

It might make sense to place name and device_node pointers members of a
port struct, and move that array of structs to the end of the
dsa_chip_data structure.

Thanks,

ALex
