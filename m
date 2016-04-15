From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/7] net: dsa: mv88e6xxx: add family to info
Date: Fri, 15 Apr 2016 21:11:49 +0200
Message-ID: <20160415191149.GA18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57984 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681AbcDOTLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 15:11:54 -0400
Content-Disposition: inline
In-Reply-To: <1460744750-13896-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2016 at 02:25:47PM -0400, Vivien Didelot wrote:
> Add an mv88e6xxx_family enum to the info structure for better family
> indentification.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6123.c |  6 ++--
>  drivers/net/dsa/mv88e6131.c |  8 ++---
>  drivers/net/dsa/mv88e6171.c |  8 ++---
>  drivers/net/dsa/mv88e6352.c | 12 ++++----
>  drivers/net/dsa/mv88e6xxx.c | 71 +++++----------------------------------------
>  drivers/net/dsa/mv88e6xxx.h | 16 +++++++++-
>  6 files changed, 40 insertions(+), 81 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
> index 02bf16c..36a0340 100644
> --- a/drivers/net/dsa/mv88e6123.c
> +++ b/drivers/net/dsa/mv88e6123.c
> @@ -18,9 +18,9 @@
>  #include "mv88e6xxx.h"
>  
>  static const struct mv88e6xxx_info mv88e6123_table[] = {
> -	{ MV88E6XXX_INFO(0x121, "Marvell 88E6123") },
> -	{ MV88E6XXX_INFO(0x161, "Marvell 88E6161") },
> -	{ MV88E6XXX_INFO(0x165, "Marvell 88E6165") },
> +	{ MV88E6XXX_INFO(6165, 0x121, "Marvell 88E6123") },
> +	{ MV88E6XXX_INFO(6165, 0x161, "Marvell 88E6161") },
> +	{ MV88E6XXX_INFO(6165, 0x165, "Marvell 88E6165") },

I think 

> +	{ MV88E6XXX_INFO(MV88E6XXX_FAMILY_6165, 0x165, "Marvell 88E6165") },

is clearer. It is hard to know what these values mean unless you go
look at the macro.

     Andrew
