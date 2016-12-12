From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Mon, 12 Dec 2016 14:54:48 +0100
Message-ID: <20161212135448.GD27057@lunn.ch>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52459 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752727AbcLLNyw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 08:54:52 -0500
Content-Disposition: inline
In-Reply-To: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 02:39:18PM +0100, Volodymyr Bendiuga wrote:
> Hashtable will make it extremely faster when inserting fdb entries
> into the forwarding database.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> ---
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> index 431e954..407e6db 100644
> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -15,6 +15,8 @@
>  #include <linux/if_vlan.h>
>  #include <linux/irq.h>
>  #include <linux/gpio/consumer.h>
> +#include <linux/crc32.h>
> +#include <linux/hashtable.h>
>  
>  #ifndef UINT64_MAX
>  #define UINT64_MAX		(u64)(~((u64)0))
> @@ -672,6 +674,16 @@ struct mv88e6xxx_info {
>  	const struct mv88e6xxx_ops *ops;
>  };
>  
> +struct pvec_tbl_entry {

Please use the mv88e6xxx_ prefix.

       Andrew
