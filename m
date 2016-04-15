From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/7] net: dsa: mv88e6xxx: add switch info
Date: Fri, 15 Apr 2016 21:13:57 +0200
Message-ID: <20160415191357.GB18523@lunn.ch>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460744750-13896-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460744750-13896-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 02:25:46PM -0400, Vivien Didelot wrote:
> Add a new switch info structure which will be later extended to store
> switch models static information, such as product number, name, number
> of ports, number of databases, etc.
> 
> Merge the lookup function in the probing code, so that we avoid multiple
> checking of the MII bus, as well a multiple ID reading.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6123.c |  8 +++---
>  drivers/net/dsa/mv88e6131.c | 10 +++----
>  drivers/net/dsa/mv88e6171.c | 10 +++----
>  drivers/net/dsa/mv88e6352.c | 14 +++++-----
>  drivers/net/dsa/mv88e6xxx.c | 67 +++++++++++++++++++--------------------------
>  drivers/net/dsa/mv88e6xxx.h | 14 ++++++----
>  6 files changed, 58 insertions(+), 65 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
> index 00c1121..02bf16c 100644
> --- a/drivers/net/dsa/mv88e6123.c
> +++ b/drivers/net/dsa/mv88e6123.c
> @@ -17,10 +17,10 @@
>  #include <net/dsa.h>
>  #include "mv88e6xxx.h"
>  
> -static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
> -	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
> -	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
> -	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
> +static const struct mv88e6xxx_info mv88e6123_table[] = {
> +	{ MV88E6XXX_INFO(0x121, "Marvell 88E6123") },
> +	{ MV88E6XXX_INFO(0x161, "Marvell 88E6161") },
> +	{ MV88E6XXX_INFO(0x165, "Marvell 88E6165") },

Why replace PORT_SWITCH_ID_6123 with the magic number 0x121?

    Andrew
