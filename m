From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip driver
Date: Fri, 04 Apr 2008 18:06:17 -0400
Message-ID: <47F6A659.7000100@garzik.org>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee>	<47F69FBE.3020308@garzik.org> <20080404.150249.132264075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, cebbert@redhat.com, netdev@vger.kernel.org,
	grundler@parisc-linux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51446 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbYDDWGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 18:06:22 -0400
In-Reply-To: <20080404.150249.132264075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 04 Apr 2008 17:38:06 -0400
> 
>> Meelis Roos wrote:
>>> CE> We have two reports that agree the tulip driver doesn't work for
>>> CE> the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
>>> CE> and also claims the same PCI ID.
>>>
>>> NAK, dmfe does not work on some Sparc64 machines but tulip does.
>>>
>>> I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
>>> 31)).
>>> tulip driver works for them, dmfe doesn't. Tried with 2.6.25-rc7, first 
>>> it
>>> gets MAC addresses all zeroed and second, it only results in Tx 
>>> timeouts.
>> At the very least, it sounds like some SROM parsing problems on dmfe's 
>> part -- assuming a standard SROM when sparc64 provides a more 
>> complicated one.
> 
> With the onboard Sparc64 davicoms, the SROM is essentially empty.

In this case, should dmfe be retrieving the MAC address via

	addr = of_get_property(dp, "local-mac-address", &len);

as tulip is doing?

One thing that seems quite obvious is that dmfe is missing all the 
CONFIG_SPARC goodies that tulip has.

	Jeff



