From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 07/11] r8169:update rtl8168f pcie ephy parameter
Date: Wed, 7 Jan 2015 16:45:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC2C99@AcuExch.aculab.com>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
 <1420648826-12972-8-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Chunhao Lin' <hau@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420648826-12972-8-git-send-email-hau@realtek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin
> rtl8168f may return to PCIe L0 from PCIe L0s low power mode too slow.
> The following ephy parameters are for this issue.
> { 0x00, 0x0000,	0x0008 }
> { 0x0c, 0x3df0,	0x0200 }
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 1874583..bafa132 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5852,7 +5852,9 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
>  		{ 0x06, 0x00c0,	0x0020 },
>  		{ 0x08, 0x0001,	0x0002 },
>  		{ 0x09, 0x0000,	0x0080 },
> -		{ 0x19, 0x0000,	0x0224 }
> +		{ 0x19, 0x0000,	0x0224 },
> +		{ 0x00, 0x0000,	0x0008 },
> +		{ 0x0c, 0x3df0,	0x0200 }

I can't help feeling these lines all require short comments.

	David
