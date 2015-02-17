From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] colons are invalid characters in netdev names
Date: Wed, 18 Feb 2015 00:46:06 +0100
Message-ID: <54E3D2BE.30305@gmx.de>
References: <1424214942-17581-1-git-send-email-mthode@mthode.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthew Thode <mthode@mthode.org>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424214942-17581-1-git-send-email-mthode@mthode.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18.02.2015 00:15, Matthew Thode wrote:
> colons are used as a separator in netdev device lookup in dev_ioctl.c
> 
> Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME
> 
> Signed-off-by: Matthew Thode <mthode@mthode.org>
> ---
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d030575..e9b6d5a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -942,7 +942,7 @@ bool dev_valid_name(const char *name)
>  		return false;
>  	if (strlen(name) >= IFNAMSIZ)
>  		return false;
> -	if (!strcmp(name, ".") || !strcmp(name, ".."))
> +	if (!strcmp(name, ".") || !strcmp(name, "..") || !strcmp(name, ":"))
>  		return false;
>  
>  	while (*name) {
> 

Hi,

that check should be done in the loop below, shouldn't it?

Regards,
Lino
