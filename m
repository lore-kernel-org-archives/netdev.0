From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 1/1] amd-xgbe: fix unused variable compilation
 warning in phylib driver
Date: Mon, 9 Jun 2014 14:07:28 -0500
Message-ID: <539605F0.9080701@amd.com>
References: <20140607090748.GA11521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0184.outbound.protection.outlook.com ([207.46.163.184]:48474
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752679AbaFITHu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:07:50 -0400
In-Reply-To: <20140607090748.GA11521@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2014 04:07 AM, Francois Romieu wrote:
> Fix following compilation warning:
> [...]
>    CC      drivers/net/phy/amd-xgbe-phy.o
> drivers/net/phy/amd-xgbe-phy.c:1353:30: warning:
> =E2=80=98amd_xgbe_phy_ids=E2=80=99 defined but not used [-Wunused-var=
iable]
>   static struct mdio_device_id amd_xgbe_phy_ids[] =3D {
>                                ^
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

> ---
>   drivers/net/phy/amd-xgbe-phy.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgb=
e-phy.c
> index d4b1c81..b57c224 100644
> --- a/drivers/net/phy/amd-xgbe-phy.c
> +++ b/drivers/net/phy/amd-xgbe-phy.c
> @@ -1350,7 +1350,7 @@ static void __exit amd_xgbe_phy_exit(void)
>   module_init(amd_xgbe_phy_init);
>   module_exit(amd_xgbe_phy_exit);
>
> -static struct mdio_device_id amd_xgbe_phy_ids[] =3D {
> +static struct mdio_device_id __maybe_unused amd_xgbe_phy_ids[] =3D {
>   	{ XGBE_PHY_ID, XGBE_PHY_MASK },
>   	{ }
>   };
>
