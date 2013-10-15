From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] drivers: net: phy: marvell.c: removed checkpatch.pl warnings
Date: Tue, 15 Oct 2013 21:12:40 +0400
Message-ID: <525D7788.3010803@cogentembedded.com>
References: <1380514004-8701-1-git-send-email-avi.kp.137@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, michal.simek@xilinx.com, lars@metafoo.de,
	RHoover@digilentinc.com, netdev@vger.kernel.org
To: Avinash kumar <avi.kp.137@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:40041 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759290Ab3JORNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 13:13:44 -0400
Received: by mail-la0-f43.google.com with SMTP id ec20so944665lab.2
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 10:13:43 -0700 (PDT)
In-Reply-To: <1380514004-8701-1-git-send-email-avi.kp.137@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/30/2013 08:06 AM, Avinash kumar wrote:

> removes following warnings-
> drivers/net/phy/marvell.c:37: WARNING: Use #include <linux/io.h> instead of <asm/io.h>
> drivers/net/phy/marvell.c:39: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

> Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>
> ---
>   drivers/net/phy/marvell.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index 2e91477..2e3c778e 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -34,9 +34,9 @@
>   #include <linux/marvell_phy.h>
>   #include <linux/of.h>
>
> -#include <asm/io.h>
> +#include <linux/io.h>
>   #include <asm/irq.h>
> -#include <asm/uaccess.h>
> +#include <linux/uaccess.h>

    You should move these #include's to the group of <linux/> #include's  now.

WBR, Sergei
