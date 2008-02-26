From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Tue, 26 Feb 2008 00:48:19 -0700
Message-ID: <20080226074819.GA27484@colo.lackof.org>
References: <200801262158.12016.linux@rainbow-software.org> <200801302123.07783.linux@rainbow-software.org> <20080218032111.GA7970@colo.lackof.org> <200802181740.44196.linux@rainbow-software.org> <20080225071505.GC26674@colo.lackof.org> <47C26E78.1040103@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Ondrej Zary <linux@rainbow-software.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:48296 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756157AbYBZHsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 02:48:31 -0500
Content-Disposition: inline
In-Reply-To: <47C26E78.1040103@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 02:30:00AM -0500, Jeff Garzik wrote:
> Grant Grundler wrote:
>> On Mon, Feb 18, 2008 at 05:40:42PM +0100, Ondrej Zary wrote:
>>> I think that de2104x driver should be removed (or at least its 
>>> MODULE_DEVICE_TABLE) and MODULE_DEVICE_TABLE with only 21040 and 21041 
>>> PCI IDs added to de4x5.
>>>
>>> I can send a patch if this is acceptable.
>> It's acceptable to me. Jeff? (jgarzik)
>
> NAK, sorry, for two reasons:
>
> 1) we don't delete otherwise clean, working drivers

Just to be clear - he's not trying to remove the driver.
He's just interested in making de4x5 the "default" for this set of boards
by doctoring with the pci device ids each driver will claim.

>     simply because of a bug triggered by unplugging a cable.

Ondrej would be happy to test any patches sent. Tracking this sort
of bug down usually isn't trivial as the statement above implies.

> 2) de4x5 needs to go away.

Ok. I'd prefer to wait until someone demonstrates de2104x driver is a fully
functional alternative for all the PCI Ids it claims.

thanks,
grant
