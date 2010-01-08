From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/: use DEFINE_PCI_DEVICE_TABLE()
Date: Thu, 07 Jan 2010 23:54:44 -0800 (PST)
Message-ID: <20100107.235444.238609921.davem@davemloft.net>
References: <1262903146.10429.83.camel@Joe-Laptop.home>
	<4B465FF0.80802@garzik.org>
	<20100108073447.GA4070@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, joe@perches.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752870Ab0AHHyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 02:54:53 -0500
In-Reply-To: <20100108073447.GA4070@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 8 Jan 2010 09:34:47 +0200

> On Thu, Jan 07, 2010 at 05:28:00PM -0500, Jeff Garzik wrote:
>> On 01/07/2010 05:25 PM, Joe Perches wrote:
>> > On Thu, 2010-01-07 at 23:58 +0200, Alexey Dobriyan wrote:
>> >> Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into correct section
>> >> in every case.
>> >
>> > Good idea, but aren't there are some tables that are not const?
>> 
>> I hope not...  those tables are read by userland tools.
> 
> I checked non-static ones, they are readonly.
> and PCI layer expects them to be readonly.

Great, patch applied, thanks!
