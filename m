From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the
 sizeof operator by parentheses
Date: Mon, 26 Sep 2016 16:00:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: 'SF Markus Elfring' <elfring@users.sourceforge.net>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:64479 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034882AbcIZQDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 12:03:42 -0400
In-Reply-To: <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: SF Markus Elfring
> Sent: 26 September 2016 16:45
...
> The script "checkpatch.pl" can point information out like the following.
> 
> WARNING: sizeof … should be sizeof(…)
...
> ---
>  drivers/isdn/gigaset/common.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
> index 2e9382f..d901ed7 100644
> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
>  {
>  	unsigned char outbuf[80];
>  	unsigned char c;
> -	size_t space = sizeof outbuf - 1;
> +	size_t space = sizeof(outbuf - 1);

wrong ...
think that is 7 instead of 79.

	David
