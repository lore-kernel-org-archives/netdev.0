From: michael trimarchi <trimarchi@gandalf.sssup.it>
Subject: Re: dm9000: add set_mac_address()
Date: Sun, 12 Aug 2007 22:54:34 +0200
Message-ID: <20070812205434.GC27490@gandalf.sssup.it>
References: <20070812192741.GB27490@gandalf.sssup.it> <200708122338.08523.mb@bu3sch.de> <200708122345.30386.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:34588 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759511AbXHLV5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 17:57:32 -0400
Content-Disposition: inline
In-Reply-To: <200708122345.30386.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 11:45:30PM +0200, Michael Buesch wrote:
> On Sunday 12 August 2007 23:38:08 Michael Buesch wrote:
> > On Sunday 12 August 2007 21:27:41 Michael Trimarchi wrote:
> > > Implement set_mac_address() for the dm9000 driver.  This allows changing
> > > the mac address of the interface.
[...]
> > 
> > That is broken on BigEndian architectures.
ok. I'll check it.
> > 
> 
> And is it really desired to change the mac in the ROM here?
> I'd say this should only write the mac to the device registers
> (filters and so on).
Many drivers do that in this way. You can change the MAC address for example
after flashing an arm board using ifconfig eth0 hw <mac address>. 
> 
> -- 
> Greetings Michael.
Cheers
