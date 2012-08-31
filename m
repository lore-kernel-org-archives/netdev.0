From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169: add D-Link DGE-560T identifiers.
Date: Fri, 31 Aug 2012 16:28:52 -0400 (EDT)
Message-ID: <20120831.162852.1143438231808755797.davem@davemloft.net>
References: <20120829194037.GB6389@electric-eye.fr.zoreil.com>
	<1346308591.17040.20.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, in@joblog.ru
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab2HaU2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:28:54 -0400
In-Reply-To: <1346308591.17040.20.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 29 Aug 2012 23:36:31 -0700

> On Wed, 2012-08-29 at 21:40 +0200, Francois Romieu wrote:
>> This one includes a 8168. Not to be confused with the sky2 driven
>> one whose PCI vendor and device ID are the same.
>>
>> Reported-by: Neyuki Inaya <in@joblog.ru>
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>> ---
>> 
>>  The patch applies to Linus's branch as well.
>> 
>>  drivers/net/ethernet/realtek/r8169.c | 2 ++
>>  1 file changed, 2 insertions(+)
>> 
>> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>> index b47d5b3..ab1cc56 100644
>> --- a/drivers/net/ethernet/realtek/r8169.c
>> +++ b/drivers/net/ethernet/realtek/r8169.c
>> @@ -288,6 +288,8 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
>>  	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
>>  	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
>>  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
>> +	{ PCI_VENDOR_ID_DLINK,			0x4300,
>> +		PCI_VENDOR_ID_DLINK, 0x4b10,		 0, 0, RTL_CFG_1 },
> 
> This has no effect, as the preceding entry will match all the same
> devices.  I think you need to insert it before that.

Francois please fix up this patch, thanks.
