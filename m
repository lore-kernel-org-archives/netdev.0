From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: eepro autoport typo
Date: Tue, 29 Apr 2008 01:59:19 -0400
Message-ID: <4816B937.8020503@garzik.org>
References: <1209278643.14173.48.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53377 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYD2F7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:59:24 -0400
In-Reply-To: <1209278643.14173.48.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> Found by sparse dubious !x & y warning...hidden in the GetBit macro
> why !Word doesn't make any sense.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  drivers/net/eepro.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
> index 83bda6c..56f5049 100644
> --- a/drivers/net/eepro.c
> +++ b/drivers/net/eepro.c
> @@ -633,7 +633,7 @@ static void __init printEEPROMInfo(struct net_device *dev)
>  		printk(KERN_DEBUG " PC: %d\n", GetBit(Word,ee_PC));
>  		printk(KERN_DEBUG " TPE/AUI: %d\n", GetBit(Word,ee_TPE_AUI));
>  		printk(KERN_DEBUG " Jabber: %d\n", GetBit(Word,ee_Jabber));
> -		printk(KERN_DEBUG " AutoPort: %d\n", GetBit(!Word,ee_Jabber));
> +		printk(KERN_DEBUG " AutoPort: %d\n", !GetBit(Word,ee_AutoPort));
>  		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));

applied


