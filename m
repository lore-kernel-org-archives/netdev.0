From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] jazzsonic: printk() style fixes
Date: Fri, 25 Oct 2013 01:50:34 +0400
Message-ID: <5269962A.5050306@cogentembedded.com>
References: <1382650780-24114-1-git-send-email-tomster595@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom D'Alba <dalbat@rpi.edu>
To: Tom D'Alba <tomster595@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:53729 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab3JXVuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:50:35 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so100215lbh.35
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 14:50:34 -0700 (PDT)
In-Reply-To: <1382650780-24114-1-git-send-email-tomster595@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/25/2013 01:39 AM, Tom D'Alba wrote:

> From: Tom D'Alba <dalbat@rpi.edu>

> Fixed printk() format by adding correct KERN_ statuses.

> Reviewed-by: Nicholas Guthrie <nickg4317@gmail.com>
> Reviewed-by: Sarah Williams <swilliams704@gmail.com>
> Reviewed-by: Jason Lee <calccrypto@gmail.com>
> Signed-off-by: Tom D'Alba <dalbat@rpi.edu>
> ---
>   drivers/net/ethernet/natsemi/jazzsonic.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
> index 79257f7..3a04d32 100644
> --- a/drivers/net/ethernet/natsemi/jazzsonic.c
> +++ b/drivers/net/ethernet/natsemi/jazzsonic.c
> @@ -135,7 +135,7 @@ static int sonic_probe1(struct net_device *dev)
>   	 */
>   	silicon_revision = SONIC_READ(SONIC_SR);
>   	if (sonic_debug > 1)
> -		printk("SONIC Silicon Revision = 0x%04x\n",silicon_revision);
> +	  printk(KERN_INFO "SONIC Silicon Revision = 0x%04x\n",silicon_revision);

    Please don't change the indentation.

> @@ -143,13 +143,13 @@ static int sonic_probe1(struct net_device *dev)
>   		i++;
>
>   	if (known_revisions[i] == 0xffff) {
> -		printk("SONIC ethernet controller not found (0x%4x)\n",
> +		printk(KERN_ERR "SONIC ethernet controller not found (0x%4x)\n",
>   		       silicon_revision);
>   		goto out;
>   	}
>
>   	if (sonic_debug  &&  version_printed++ == 0)
> -		printk(version);
> +	      printk(KERN_INFO version);

    Same here.

WBR, Sergei
