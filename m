From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH v2 0/4] introduce devm_mdiobus_alloc/free and clean up
 davinci mdio
Date: Sat, 19 Apr 2014 18:02:21 +0530
Message-ID: <CA+V-a8t+U5cqbB5Cm0JZV-=yy6OeemCRrLGUd8-ET+7E4hYmRw@mail.gmail.com>
References: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Santosh Shilimkar <santosh.shilimkar@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, LDOC <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Grygorii,

Thanks for the patches!


On Fri, Apr 18, 2014 at 10:54 PM, Grygorii Strashko
<grygorii.strashko@ti.com> wrote:
> Introduce a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.
>
> Clean up Davinci MDIO driver and use new devm API.
>
> Changes in v2:
> - minor comments taken into account
> - additional patches added for cleaning up Davinci MDIO driver
>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
>
> Grygorii Strashko (4):
>   mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
>   net: davinci_mdio: use devm_* api
>   net: davinci_mdio: drop pinctrl_pm_select_default_state from probe
>   net: davinci_mdio: simplify IO memory mapping
>
Tested on DA850EVM.

Acked-and-tested-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar Lad

>  Documentation/driver-model/devres.txt  |    4 ++
>  drivers/net/ethernet/ti/davinci_mdio.c |   48 ++++------------------
>  drivers/net/phy/mdio_bus.c             |   68 ++++++++++++++++++++++++++++++++
>  include/linux/phy.h                    |    2 +
>  4 files changed, 82 insertions(+), 40 deletions(-)
>
> --
> 1.7.9.5
>
