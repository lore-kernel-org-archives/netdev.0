From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 1/4] udp: Add udp_sock_create for UDP tunnels to open
 listener socket
Date: Mon, 14 Jul 2014 10:22:01 +0530
Message-ID: <53C361F1.5060500@gmail.com>
References: <alpine.DEB.2.02.1407131942300.25018@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52784 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbaGNExN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 00:53:13 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so3322988pab.6
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 21:53:12 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1407131942300.25018@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/2014 08:19 AM, Tom Herbert wrote:
> diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
> new file mode 100644
> index 0000000..61ec1a6
> --- /dev/null
> +++ b/net/ipv4/udp_tunnel.c
> @@ -0,0 +1,100 @@
> +#include <linux/module.h>
> +#include <linux/errno.h>
> +#include <linux/socket.h>
> +#include <linux/udp.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <net/udp.h>
> +#include <net/udp_tunnel.h>
> +#include <net/net_namespace.h>
> +

Its looks good if includes in alphabetical order...  :-)


-- 
Regards,
Varka Bhadram.
