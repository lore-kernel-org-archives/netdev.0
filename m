From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Wed, 30 Jan 2008 05:38:38 -0500
Message-ID: <47A053AE.7050900@garzik.org>
References: <20080130094440.GA4652@havoc.gtf.org> <20080130102116.GA20846@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58671 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052AbYA3Kil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 05:38:41 -0500
In-Reply-To: <20080130102116.GA20846@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam Ravnborg wrote:
>> Jeff Garzik (1):
>>       [netdrvr] sis190: build fix
> 
> But you did it wrong...
> sis190.c b/drivers/net/sis190.c
>> index b570402..2e9e88b 100644
>> --- a/drivers/net/sis190.c
>> +++ b/drivers/net/sis190.c
>> @@ -326,7 +326,7 @@ static const struct {
>>  	{ "SiS 191 PCI Gigabit Ethernet adapter" },
>>  };
>>  
>> -static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
>> +static struct pci_device_id sis190_pci_tbl[] = {
>>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
>>  	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
>>  	{ 0, },
> 
> The __devinitdata is OK, it is the following _devinitdata that had to be _devinitconst.

Cool.  Either way is fine with me.  I just wanted to get a build fix 
upstream ASAP, one I was sure would work.

	Jeff



