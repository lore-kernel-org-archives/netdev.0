From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Mon, 25 Feb 2008 02:30:00 -0500
Message-ID: <47C26E78.1040103@pobox.com>
References: <200801262158.12016.linux@rainbow-software.org> <200801302123.07783.linux@rainbow-software.org> <20080218032111.GA7970@colo.lackof.org> <200802181740.44196.linux@rainbow-software.org> <20080225071505.GC26674@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ondrej Zary <linux@rainbow-software.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47676 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752791AbYBYHaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 02:30:22 -0500
In-Reply-To: <20080225071505.GC26674@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> On Mon, Feb 18, 2008 at 05:40:42PM +0100, Ondrej Zary wrote:
>> I think that de2104x driver should be removed (or at least its 
>> MODULE_DEVICE_TABLE) and MODULE_DEVICE_TABLE with only 21040 and 21041 PCI 
>> IDs added to de4x5.
>>
>> I can send a patch if this is acceptable.
> 
> It's acceptable to me. Jeff? (jgarzik)

NAK, sorry, for two reasons:

1) we don't delete otherwise clean, working drivers simply because of a 
bug triggered by unplugging a cable.

2) de4x5 needs to go away.

	Jeff


