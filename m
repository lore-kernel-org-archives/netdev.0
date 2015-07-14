From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rfkill-gpio: Add support for the Realtek 8723 BT
Date: Tue, 14 Jul 2015 08:20:02 -0500
Message-ID: <55A50C82.4040107@lwfinger.net>
References: <1436825494.20249.47.camel@hadess.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bastien Nocera <hadess@hadess.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436825494.20249.47.camel@hadess.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/13/2015 05:11 PM, Bastien Nocera wrote:
> http://thread.gmane.org/gmane.linux.kernel.wireless.general/127706/focu
> s=127896
>
> Signed-off-by: Bastien Nocera <hadess@hadess.net>

Bastien,

The subject of this patch needs a bit more detail. I know that you mean the 
RTL8723B versions of the Bluetooth devices. The subject should say this.

The commit message needs a bit more detail. Referencing the E-mail thread is OK, 
but a bit more is needed. What fails without this change?

To help keep that patches straight, change the next submission to say "[PATCH 
V2]" in the subject. In addition, after the ---, add a section saying what 
changed in V2. That info is not retained in the final commit message in the 
repo, but it can be very useful to a maintainer.

Larry

>
> ---
>   net/rfkill/rfkill-gpio.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index d5d58d9..9471024 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -168,6 +168,7 @@ static const struct acpi_device_id
> rfkill_acpi_match[] = {
>   	{ "BCM2E3D", RFKILL_TYPE_BLUETOOTH },
>   	{ "BCM2E40", RFKILL_TYPE_BLUETOOTH },
>   	{ "BCM2E64", RFKILL_TYPE_BLUETOOTH },
> +	{ "OBDA8723", RFKILL_TYPE_BLUETOOTH },
>   	{ "BCM4752", RFKILL_TYPE_GPS },
>   	{ "LNV4752", RFKILL_TYPE_GPS },
>   	{ },
>
