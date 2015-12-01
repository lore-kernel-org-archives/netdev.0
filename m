From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/6] net: thunderx: Force to load octeon-mdio before bgx
 driver.
Date: Tue, 1 Dec 2015 16:17:56 +0300
Message-ID: <565D9E04.8010203@cogentembedded.com>
References: <y> <1448961223-41888-2-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: Sunil Goutham <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448961223-41888-2-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/1/2015 12:13 PM, Sunil Goutham wrote:

> From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
>
> Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c |    3 +++
>   drivers/net/ethernet/cavium/thunder/thunder_bgx.h |    1 +
>   2 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index 180aa9f..1fb72dd 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -1009,6 +1009,9 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>   	struct bgx *bgx = NULL;
>   	u8 lmac;
>
> +	/*Load octeon mdio driver*/

    Please insert spaces after /* and before */ (unless it's a common comment 
style in this driver).

[...]

MBR, Sergei
