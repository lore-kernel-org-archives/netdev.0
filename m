From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 7/9] tlan: Make autonegotiation faster
Date: Wed, 28 May 2014 18:11:06 +0400
Message-ID: <5385EE7A.2030501@cogentembedded.com>
References: <1401226727-5508-1-git-send-email-linux@rainbow-software.org> <1401226727-5508-8-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>,
	Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401226727-5508-8-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/28/2014 01:38 AM, Ondrej Zary wrote:

> Reduce the autonegotiation poll interval from 8 seconds to 2.
> This greatly reduces the time needed to detect link presence,
> especially on Olicom cards at 10 Mbps (two autonegoatiations required).

> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>   drivers/net/ethernet/ti/tlan.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
> index 628a779..007c2fe 100644
> --- a/drivers/net/ethernet/ti/tlan.c
> +++ b/drivers/net/ethernet/ti/tlan.c
> @@ -2699,7 +2699,7 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
>   		/* Wait for 8 sec to give the process
>   		 * more time.  Perhaps we should fail after a while.
>   		 */
> -		tlan_set_timer(dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN);
> +		tlan_set_timer(dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN);

    The inner () not needed but space around * wouldn't hurt.

>   		return;
>   	}

WBR, Sergei
