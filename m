From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 00/13] net-caif: introducing CAIF protocol stack
Date: Fri, 22 Jan 2010 11:11:07 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E07903232096@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com> <1264153397.3469.33.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stefano.babic@babic.homelinux.org>, <randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:61259 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab0AVKND convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 05:13:03 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1264153397.3469.33.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Sjur,
> 
>> This patch-set introduces the CAIF protocol Stack.
>> 
>> The "Communication CPU to Application CPU Interface" (CAIF) is a
>> packet based connection-oriented MUX protocol developed by
>> ST-Ericsson for use with its modems. 
>> 
>> * CAIF provides a socket interface which can be used to open virtual
>>   AT channels, create and configure GPRS Data connections.
>> 
>> * A CAIF Network device is also provided for GPRS access.
>>   This interface can be managed with socket IOCTLs or RTNL.
>> 
>> * A kernel interface is provided allowing Kernel modules to use CAIF.
>> 
>> * A serial link layer layer implemented as a line discipline is
>>   currently implemented. Other link interfaces may be contributed at
>> a later stage. 
> 
> any details on potential USB, SPI or SDIO drivers?

We have a SPI driver that we could contribute, 
but I think it might need some more work before submitting it.
Also I think it would be good to have this patch set accepted before we
start on SPI.

BR/Sjur

