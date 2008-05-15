From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 20:02:21 -0300
Message-ID: <20080515230221.GC20976@khazad-dum.debian.net>
References: <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <20080515214721.GP18825@mit.edu> <482CB1FB.7080807@garzik.org> <20080515222941.GB20976@khazad-dum.debian.net> <482CBCC6.6010905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Theodore Tso <tytso@mit.edu>,
	Chris Peterson <cpeterso@cpeterso.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:40917 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755429AbYEOXCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 19:02:24 -0400
Content-Disposition: inline
In-Reply-To: <482CBCC6.6010905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008, Jeff Garzik wrote:
> Henrique de Moraes Holschuh wrote:
>> If anyone wants to poke at it, get the Debian rng-tools source package.
>> It directly supports the VIA PadLock in userspace in a suitably paranoid
>> mode (checks that the RNG was not reprogrammed at every read), and does
>> multithreading so that FIPS and output processing does not block (nor
>> gets blocked) by /dev/hw_random reading, etc.
>
> Neat.  I always did prefer VIA padlock in userspace.
>
> I just sorta assumed a buffering, interrupt-driver TPM RNG driver would  
> be better than doing it from userspace, but maybe that was a bad  
> assumption to make on my part.  It should be quite doable to support TPM  
> RNG entirely via userspace, at any rate.

I will tell you what.  If someone manages to get trousers to actually
*work* for data binding and sealing to the TPM in a ThinkPad T43 with an
NSC/Winbond TPM (their "sup3r s3kr1t TPM-inside-the-SuperIO 8394T" crap
one needs a NDA to get the documentation for), and I manage to duplicate
it (i.e. make it work here too), I will write the rng-tools trousers
interface code (at least for the Debian version) :-)

The kernel TPM driver works, the BIOS works, and I have the PCRs updated
properly during boot, but trousers get the tpm pubek key wrong for some
reason (the kernel driver can read it just fine).  The chip is good,
IBM's stuff worked just fine with it.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
