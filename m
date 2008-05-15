From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 18:44:22 -0400
Message-ID: <482CBCC6.6010905@garzik.org>
References: <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <20080515214721.GP18825@mit.edu> <482CB1FB.7080807@garzik.org> <20080515222941.GB20976@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>,
	Chris Peterson <cpeterso@cpeterso.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54333 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbYEOWox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 18:44:53 -0400
In-Reply-To: <20080515222941.GB20976@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Henrique de Moraes Holschuh wrote:
> If anyone wants to poke at it, get the Debian rng-tools source package.
> It directly supports the VIA PadLock in userspace in a suitably paranoid
> mode (checks that the RNG was not reprogrammed at every read), and does
> multithreading so that FIPS and output processing does not block (nor
> gets blocked) by /dev/hw_random reading, etc.


Neat.  I always did prefer VIA padlock in userspace.

I just sorta assumed a buffering, interrupt-driver TPM RNG driver would 
be better than doing it from userspace, but maybe that was a bad 
assumption to make on my part.  It should be quite doable to support TPM 
RNG entirely via userspace, at any rate.

	Jeff


