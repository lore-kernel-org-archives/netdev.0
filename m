From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] netdrvr/ibmlana: move away from legacy MCA API
Date: Mon, 29 Oct 2007 15:41:34 -0400
Message-ID: <4726376E.3080608@garzik.org>
References: <47dcd058deaaf90802c720df243f5c8b26ed9de3.1193686354.git.jeff@garzik.org> <cbe6f335b6d7f4199e235a4925d1c931dd512fe5.1193686354.git.jeff@garzik.org> <Pine.LNX.4.64.0710292039020.26070@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638AbXJ2Tli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 15:41:38 -0400
In-Reply-To: <Pine.LNX.4.64.0710292039020.26070@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Oct 29 2007 15:33, Jeff Garzik wrote:
>> +#if 0 /* info available elsewhere, but this is kept for reference */
> 
> It is available in the git history, yes, is it still needed for reference?

it's there to see if anyone complains at its removal :)


>> +static short ibmlana_adapter_ids[] __initdata = {
>> +	IBM_LANA_ID,
>> +	0x0000
>> +};
>> +
>> +static char *ibmlana_adapter_names[] __initdata = {
>> +	"IBM LAN Adapter/A",
>> +	NULL
>> +};
> 
> Can this be const?

Not with the initdata marker, no.

	Jeff



