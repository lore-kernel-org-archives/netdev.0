From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] net: davinci_mdio: use devm_* api
Date: Fri, 04 Apr 2014 17:18:55 +0400
Message-ID: <533EB13F.5010406@cogentembedded.com>
References: <1396618825-4241-1-git-send-email-grygorii.strashko@ti.com> <1396618825-4241-3-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-doc@vger.kernel.org, Randy Dunlap <rdunlap@infradead.org>,
	linux-kernel@vger.kernel.org, santosh.shilimkar@ti.com,
	"David S. Miller" <davem@davemloft.net>,
	Jonathan Cameron <jic23@kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396618825-4241-3-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04-04-2014 17:40, Grygorii Strashko wrote:

> Use devm_* API for memory allocation and to get device's clock
> to simplify driver's code.

> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>   drivers/net/ethernet/ti/davinci_mdio.c |   21 ++++-----------------
>   1 file changed, 4 insertions(+), 17 deletions(-)

> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 0cca9de..f0f7128 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
[...]
> @@ -425,16 +417,11 @@ static int davinci_mdio_remove(struct platform_device *pdev)
>
>   	if (data->bus) {
>   		mdiobus_unregister(data->bus);
> -		mdiobus_free(data->bus);
>   	}

    Remove {} please, it's not needed anymore, according to 
Documentation/CodingStyle.

WBR, Sergei
