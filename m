From: David Miller <davem@davemloft.net>
Subject: Re: pcnet_cs: fix misuse of the equality operator.
Date: Sun, 01 Feb 2009 01:43:52 -0800 (PST)
Message-ID: <20090201.014352.138067875.davem@davemloft.net>
References: <20090131071342.2b45cbe8.komurojun-mbn@nifty.com>
	<4984DC50.6060204@gmx.de>
	<49856D35.7020702@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cord.walter@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752552AbZBAJnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:43:55 -0500
In-Reply-To: <49856D35.7020702@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cord Walter <cord.walter@gmx.de>
Date: Sun, 01 Feb 2009 10:36:53 +0100

> Now with properly formatted patch...
 ...
> 06:44:03.000000000 +0900
> +++ linux-2.6.29-rc3/drivers/net/pcmcia/pcnet_cs.c	2009-01-31
> 06:44:21.000000000 +0900
> @@ -586,7 +586,7 @@ static int pcnet_config(struct pcmcia_de
>      }
> 
>      if ((link->conf.ConfigBase == 0x03c0)
> - -	&& (link->manf_id == 0x149) && (link->card_id = 0xc1ab)) {
> +	&& (link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
>  	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");

Still looks corrupted here.
