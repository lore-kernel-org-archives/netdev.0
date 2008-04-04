From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip driver
Date: Fri, 04 Apr 2008 17:38:06 -0400
Message-ID: <47F69FBE.3020308@garzik.org>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbYDDViK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 17:38:10 -0400
In-Reply-To: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meelis Roos wrote:
> CE> We have two reports that agree the tulip driver doesn't work for
> CE> the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
> CE> and also claims the same PCI ID.
> 
> NAK, dmfe does not work on some Sparc64 machines but tulip does.
> 
> I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
> 31)).
> tulip driver works for them, dmfe doesn't. Tried with 2.6.25-rc7, first 
> it
> gets MAC addresses all zeroed and second, it only results in Tx 
> timeouts.

At the very least, it sounds like some SROM parsing problems on dmfe's 
part -- assuming a standard SROM when sparc64 provides a more 
complicated one.


> This issue was debugged somemonths ago on sparclinux mailing list. DaveM
> fixed some bugs IIRC but it still does not work.

URL to more info?

Overall we need someone to either (a) work on tulip to get it working 
with popular 9102's, or (b) work on dmfe to get it working on sparc64... 
  Installers and users will continue to be confused by the present 
situation, where the same PCI ID is claimed by two different drivers, 
and you just sorta haveta "know" which one is right.

	Jeff



