From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 02/08] r8169: identify different registers.
Date: Sun, 02 Jan 2011 18:58:06 -0800 (PST)
Message-ID: <20110102.185806.226760329.davem@davemloft.net>
References: <20110102233617.GC5780@electric-eye.fr.zoreil.com>
	<1294023131.3167.138.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	hayeswang@realtek.com, dwmw2@infradead.org
To: benh@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203Ab1ACC5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 21:57:35 -0500
In-Reply-To: <1294023131.3167.138.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <benh@debian.org>
Date: Mon, 03 Jan 2011 02:52:11 +0000

> On Mon, 2011-01-03 at 00:36 +0100, Francois Romieu wrote:
>> Documentation (sort of).
>> 
>> The location are the same, the values are the same but it is
>> just accidental. Note that the 810x could cope with a smaller
>> value as it does not support jumbo frames.
>> 
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>> Cc: Hayes <hayeswang@realtek.com>
>> ---
>>  drivers/net/r8169.c |   22 ++++++++++++++--------
>>  1 files changed, 14 insertions(+), 8 deletions(-)
>> 
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index 3124462..8aa92ad 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
> [...]
>> @@ -3036,7 +3042,7 @@ static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
>>  {
>>  	rtl_hw_start_8168bb(ioaddr, pdev);
>>  
>> -	RTL_W8(EarlyTxThres, EarlyTxThld);
>> +	RTL_W8(MaxTxPacketSize, 0x3f);
> [...]
> 
> Shouldn't the value here be written as TxPacketMax?

Yep, looks that way to me too.

Otherwise why add the new TxPacketMax definition :-)
