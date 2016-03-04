From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 08/16] net: fec: eliminate calls to
 fec_enet_get_prevdesc
Date: Fri, 4 Mar 2016 09:05:42 -0700
Message-ID: <56D9B256.7040408@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <1456360619-24390-9-git-send-email-troy.kisky@boundarydevices.com>
 <VI1PR0401MB18556C9393B8629330062B8EFFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
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
To: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34125 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759006AbcCDQFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:05:44 -0500
Received: by mail-pa0-f51.google.com with SMTP id fy10so36977097pac.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:05:43 -0800 (PST)
In-Reply-To: <VI1PR0401MB18556C9393B8629330062B8EFFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/2016 2:33 AM, Fugang Duan wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Thursday, February 25, 2016 8:37 AM
>> To: netdev@vger.kernel.org; davem@davemloft.net; b38611@freescale.com
>> Cc: fabio.estevam@freescale.com; l.stach@pengutronix.de; andrew@lunn.ch;
>> tremyfr@gmail.com; linux@arm.linux.org.uk; linux-arm-
>> kernel@lists.infradead.org; laci@boundarydevices.com; shawnguo@kernel.org;
>> johannes@sipsolutions.net; stillcompiling@gmail.com;
>> sergei.shtylyov@cogentembedded.com; arnd@arndb.de; Troy Kisky
>> <troy.kisky@boundarydevices.com>
>> Subject: [PATCH net-next V2 08/16] net: fec: eliminate calls to
>> fec_enet_get_prevdesc
>>
>> This shrinks the code a little.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>> ---
>>  drivers/net/ethernet/freescale/fec_main.c | 37 +++++++++----------------------
>>  1 file changed, 11 insertions(+), 26 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index 6ceb5f9..b5ed287 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -758,6 +758,7 @@ static void fec_enet_bd_init(struct net_device *dev)
>>  	struct bufdesc *bdp;
>>  	unsigned int i;
>>  	unsigned int q;
>> +	unsigned status;
> 
> Should be unsigned int status;
> 


Fine



Thanks
