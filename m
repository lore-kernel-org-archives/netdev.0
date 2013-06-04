From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 1/8] drivers: net: phy: at803x code cleanup on
 register and unregister driver
Date: Tue, 04 Jun 2013 16:02:06 +0400
Message-ID: <51ADD73E.40405@cogentembedded.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com> <1370326212-17580-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org,
	benoit.cousson@linaro.org, paul@pwsan.com,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1370326212-17580-2-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04-06-2013 10:10, Mugunthan V N wrote:

> Make use of phy_drivers_register/phy_drivers_unregister to register/unregister
> multiple phy drivers in a single module.

> Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>   drivers/net/phy/at803x.c |   35 ++++++++++-------------------------
>   1 file changed, 10 insertions(+), 25 deletions(-)

> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 45cbc10..a1063e1 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -108,8 +108,9 @@ static int at803x_config_init(struct phy_device *phydev)
>   	return 0;
>   }
>
> -/* ATHEROS 8035 */
> -static struct phy_driver at8035_driver = {
> +static struct phy_driver at803x_driver[] = {
> +{
> +	/* ATHEROS 8035 */
>   	.phy_id		= 0x004dd072,
>   	.name		= "Atheros 8035 ethernet",
>   	.phy_id_mask	= 0xffffffef,

     That's improper indentation. Needs to be shifted by one tab.

> @@ -136,32 +135,18 @@ static struct phy_driver at8030_driver = {
>   	.driver		= {
>   		.owner = THIS_MODULE,
>   	},
> -};
> +} };

    Looks ugly...

WBR, Sergei

