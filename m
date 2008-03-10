From: Joe Perches <joe@perches.com>
Subject: Re: drivers/net/tokenring/smctr.c: logical-bitwise or confusion?
Date: Sun, 09 Mar 2008 18:27:27 -0700
Message-ID: <1205112447.656.111.camel@localhost>
References: <993737.45508.qm@web65610.mail.ac4.yahoo.com>
	 <47D48BEF.2070103@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>, jschlst@samba.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@sw.ru>
To: Roel Kluin <12o3l@tiscali.nl>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4460 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbYCJB3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 21:29:04 -0400
In-Reply-To: <47D48BEF.2070103@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-03-10 at 02:16 +0100, Roel Kluin wrote:
> diff --git a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
> index 8909050..8ae5837 100644
> --- a/drivers/net/tokenring/smctr.c
> +++ b/drivers/net/tokenring/smctr.c
> @@ -3413,7 +3413,7 @@ static int smctr_make_tx_status_code(struct net_device *dev,
>          tsv->svi = TRANSMIT_STATUS_CODE;
>          tsv->svl = S_TRANSMIT_STATUS_CODE;
>  
> -        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);
> +        tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) | IBM_PASS_SOURCE_ADDR);
>  
>          /* Stripped frame status of Transmitted Frame */
>          tsv->svv[1] = tx_fstatus & 0xff;

This has been posted a few times over the last 6 months.

for instance:
http://www.ussg.iu.edu/hypermail/linux/kernel/0710.1/0887.html

Somebody please apply it.

