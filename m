From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 13/16] net: fec: print more debug info in
 fec_timeout
Date: Fri, 4 Mar 2016 12:06:58 -0700
Message-ID: <56D9DCD2.2090009@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-14-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18552AB3E4128E412273B439FFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
 <56D9B238.2040400@boundarydevices.com>
 <1457112947.4044.133.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Joe Perches <joe@perches.com>, Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36529 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbcCDTG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 14:06:59 -0500
Received: by mail-pf0-f175.google.com with SMTP id 63so39784005pfe.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 11:06:59 -0800 (PST)
In-Reply-To: <1457112947.4044.133.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/2016 10:35 AM, Joe Perches wrote:
> On Fri, 2016-03-04 at 09:05 -0700, Troy Kisky wrote:
>> On 3/4/2016 3:06 AM, Fugang Duan wrote:
>>> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
> []
>>>> Print the current interrupt flags and mask and the interrupt state during the last
>>>> interrupt in fec_timeout.
> []
>>>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> []
>>>> @@ -1107,6 +1107,9 @@ fec_timeout(struct net_device *ndev)
>>>>  	int i;
>>>>  	uint events = 0;
>>>>
>>>> +	pr_err("%s: last=%x %x, mask %x\n", __func__, fep->last_ievents,
>>>> +	       readl(fep->hwp + FEC_IEVENT), readl(fep->hwp + FEC_IMASK));
>>>> +
>>> pr_err() -> netdev_err()
>> Sounds good
> 
> This seems like debugging information rather than
> an error a user can do anything with and if there's
> a timeout, how likely is it that the hardware is
> hosed and this would  repetitively and unnecessarily
> fill up logs?
> 
> So maybe netdev_dbg and net_ratelimit() too.
> 
> 	if (net_ratelimit()
> 		netdev_<level>(etc...)
> 
> 

This patch hasn't been helpful to me in quite a while. I'll just drop it.
I know where to get it if I need it again.


Thanks
Troy
