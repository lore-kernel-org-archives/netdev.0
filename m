From: =?ISO-8859-1?Q?Michael_B=FCsch?= <mb@bu3sch.de>
Subject: Re: [PATCH] b43: Add SDIO_DEVICE() for EW-CG1102GC
Date: Fri, 25 Jun 2010 15:29:37 +0200
Message-ID: <4C24AF41.3080101@bu3sch.de>
References: <20100625093254.9484.69877.sendpatchset@t400s> (sfid-20100625_113248_442184_13EC6E79)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Albert Herranz <albert_herranz@yahoo.es>
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100625093254.9484.69877.sendpatchset@t400s> (sfid-20100625_113248_442184_13EC6E79)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/25/2010 11:32 AM, Magnus Damm wrote:
> From: Magnus Damm<damm@opensource.se>
>
> This patch enables the EW-CG1102GC SDIO card in the b43 driver.
>
> b43-sdio mmc0:0001:1: Chip ID 14e4:4318
> ssb: Core 0 found: ChipCommon (cc 0x800, rev 0x0D, vendor 0x4243)
> ssb: Core 1 found: IEEE 802.11 (cc 0x812, rev 0x09, vendor 0x4243)
> ssb: Core 2 found: PCI (cc 0x804, rev 0x0C, vendor 0x4243)
> ssb: Core 3 found: PCMCIA (cc 0x80D, rev 0x07, vendor 0x4243)
> b43-phy0: Broadcom 4318 WLAN found (core revision 9)
> b43-phy0 debug: Found PHY: Analog 3, Type 2, Revision 7
> b43-phy0 debug: Found Radio: Manuf 0x17F, Version 0x2050, Revision 8
>
> Tested with openfwwf-5.2 using a SuperH SDHI host controller.
>
> Signed-off-by: Magnus Damm<damm@opensource.se>
> ---
>
>   drivers/net/wireless/b43/sdio.c |    1 +
>   1 file changed, 1 insertion(+)
>
> --- 0001/drivers/net/wireless/b43/sdio.c
> +++ work/drivers/net/wireless/b43/sdio.c	2010-06-25 18:20:46.000000000 +0900
> @@ -182,6 +182,7 @@ static void b43_sdio_remove(struct sdio_
>
>   static const struct sdio_device_id b43_sdio_ids[] = {
>   	{ SDIO_DEVICE(0x02d0, 0x044b) }, /* Nintendo Wii WLAN daughter card */
> +	{ SDIO_DEVICE(0x0092, 0x0004) }, /* C-guys, Inc. EW-CG1102GC */
>   	{ },
>   };
>
>

ack

-- 
Greetings Michael.
