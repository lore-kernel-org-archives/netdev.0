From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: smsc: move smsc_phy_config_init reset part
 in a soft_reset function
Date: Fri, 15 Aug 2014 18:36:39 +0400
Message-ID: <53EE1AF7.4030206@cogentembedded.com>
References: <1408089161-94989-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408089161-94989-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/15/2014 11:52 AM, Gwenhael Goavec-Merou wrote:

> On the one hand, phy_device.c provides a generic reset function if the phy
> driver does not provide a soft_reset pointer. This generic reset does not take
> into account the state of the phy, with a potential failure if the phy is in
> powerdown mode. On the other hand, smsc driver provides a function with both
> correct reset behaviour and configuration.

> This patch moves the reset part into a new smsc_phy_reset function and provides
> the soft_reset pointer to have a correct reset behaviour by default.

> Signed-off-by: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>
> ---
>   drivers/net/phy/smsc.c | 33 +++++++++++++++++++++------------
>   1 file changed, 21 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index 180c494..fda13f4 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
[...]
> @@ -142,6 +147,7 @@ static struct phy_driver smsc_phy_driver[] = {
>   	.config_aneg	= genphy_config_aneg,
>   	.read_status	= genphy_read_status,
>   	.config_init	= smsc_phy_config_init,
> +	.soft_reset		= smsc_phy_reset,

    Please align with the other ='s above here and below.

WBR, Sergei
