From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/6] net: thunderx: bgx: Add log message when setting mac
 address
Date: Mon, 8 Feb 2016 16:30:37 +0300
Message-ID: <56B8987D.7000901@cogentembedded.com>
References: <1454933272-45005-1-git-send-email-sunil.kovvuri@gmail.com>
 <1454933272-45005-6-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Robert Richter <rrichter@cavium.com>
To: sunil.kovvuri@gmail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454933272-45005-6-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/8/2016 3:07 PM, sunil.kovvuri@gmail.com wrote:

> From: Robert Richter <rrichter@cavium.com>
>
> Signed-off-by: Robert Richter <rrichter@cavium.com>
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> ---
>   drivers/net/ethernet/cavium/thunder/thunder_bgx.c |   11 ++++++++---
>   1 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index 111835b..cfee496 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
[...]
> @@ -897,10 +898,13 @@ static int acpi_get_mac_address(struct acpi_device *adev, u8 *dst)
>   		goto out;
>
>   	if (!is_valid_ether_addr(mac)) {
> +		dev_warn(dev, "MAC address invalid: %pM\n", mac);

    dev_er(), maybe?

>   		ret = -EINVAL;
>   		goto out;
>   	}
>
> +	dev_info(dev, "MAC address set to: %pM\n", mac);
> +
>   	memcpy(dst, mac, ETH_ALEN);
>   out:
>   	return ret;
[...]

MBR, Sergei
