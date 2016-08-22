From: Xander Huff <xander.huff@ni.com>
Subject: Re: [PATCH] phy: micrel: Reenable interrupts during on resume for
 ksz9031
Date: Mon, 22 Aug 2016 17:03:58 -0500
Message-ID: <57BB76CE.7080606@ni.com>
References: <1471898618-55834-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brad Mouring <brad.mouring@ni.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Nathan Sullivan <nathan.sullivan@ni.com>
To: "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471898618-55834-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/22/2016 3:43 PM, Xander Huff wrote:
> Like the ksz8081, the ksz9031 has the behavior where it will clear the interrupt
> enable bits when leaving power down. This takes advantage of the solution
> provided by f5aba91.
>
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Natinst-ReviewBoard-ID: 149877
> ---
>   drivers/net/phy/micrel.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 053e879..885ac9c 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -964,7 +964,7 @@ static struct phy_driver ksphy_driver[] = {
>   	.get_strings	= kszphy_get_strings,
>   	.get_stats	= kszphy_get_stats,
>   	.suspend	= genphy_suspend,
> -	.resume		= genphy_resume,
> +	.resume		= kszphy_resume,
>   }, {
>   	.phy_id		= PHY_ID_KSZ8873MLL,
>   	.phy_id_mask	= MICREL_PHY_ID_MASK,
>
Please disregard this patch as it was accidentally sent. Please instead refer to 
my subsequent email with the subject:
"[PATCH] phy: micrel: Reenable interrupts during resume for ksz9031"

-- 
Xander Huff
Staff Software Engineer
National Instruments
