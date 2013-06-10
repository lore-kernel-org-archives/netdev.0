From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Mon, 10 Jun 2013 19:10:41 +0100
Message-ID: <1370887841.1933.20.camel@bwh-desktop.uk.level5networks.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
	 <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
	 <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>
	 <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>
	 <51B1F56D.5000007@intel.com>
	 <1370625678.1903.26.camel@bwh-desktop.uk.level5networks.com>
	 <51B219D9.2010900@gmail.com>
	 <E31FB011129F30488D5861F383904915210BA89DEC@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <john.fastabend@gmail.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63517 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032Ab3FJSKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 14:10:46 -0400
In-Reply-To: <E31FB011129F30488D5861F383904915210BA89DEC@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-10 at 10:54 -0700, Narendra_K@Dell.com wrote:
[...]
> In the scenario of NIC partitions, universally unique identifier
> generation may have to consider that, each NIC partition which maps to
> a given physical port will have its own MAC address. (The SRIOV VF
> network interfaces could probably use PF's MAC address).  But
> generation of a universally unique physport identifier would probably
> be driver specific.

Right, I agree this has to be driver-specific.

> 2.  Also, thinking about the default value for 'physport' , could it
> be set to zero by default  ? A possible  interface could be
> 
> 0   ==>   driver did not to set the identifier
> > 0 ==> driver successfully set the identifier

I think a universally unique identifier would have to be a multibyte
value like a MAC-48, EUI-64 or 128-bit UUID - not a simple number, and
not a fixed length.  The unset value would then have a *length* of zero.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
