From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net: Use priority level to printk()
 calls
Date: Thu, 25 Aug 2016 18:17:57 -0700
Message-ID: <1472174277.4914.36.camel@perches.com>
References: <1472163761-14015-1-git-send-email-oussamamrkd2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Oussama Markad <markad.oussama@gmail.com>
To: citestra <oussamamrkd2@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0089.hostedemail.com ([216.40.44.89]:41029 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756165AbcHZBS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 21:18:58 -0400
In-Reply-To: <1472163761-14015-1-git-send-email-oussamamrkd2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-26 at 00:22 +0200, citestra wrote:
> Add priority level 'KERN_ERR' to a printk() call
[]
> diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
[]
> @@ -182,7 +182,7 @@ am79c961_ramtest(struct net_device *dev, unsigned int val)
>  	am_readbuffer(dev, 0, buffer, 65536);
>  	for (i = 0; i < 65536; i++) {
>  		if (buffer[i] != val && !error) {
> -			printk ("%s: buffer error (%02X %02X) %05X - ", dev->name, val, buffer[i], i);
> +			printk (KERN_ERR "%s: buffer error (%02X %02X) %05X - ", dev->name, val, buffer[i], i);

			netdev_err(dev, "buffer error etc...", val, ...)
