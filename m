From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Wed, 10 Jun 2009 23:55:31 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.0906102350420.31536@xanadu.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
 <1244685768.4616.22.camel@deadeye>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Martin Fuzzey <mfuzzey@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:65132 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755738AbZFKDzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 23:55:50 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KL200FQ62WJTZC0@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 10 Jun 2009 23:55:31 -0400 (EDT)
In-reply-to: <1244685768.4616.22.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009, Ben Hutchings wrote:

> On Wed, 2009-06-10 at 19:34 +0200, Martin Fuzzey wrote:
> > Allow network drivers to be configured by the kernel
> > in the same way as the userspace "ethtool" program as suggested
> > by Nicolas Pitre in a recent mailing list discussion.
[...]
> Who needs this feature?  Why not use ethtool in an initramfs?
[...]
> Forcing speed and duplex is occasionally needed to work around a link
> partner that doesn't implement autonegotiation correctly.  I don't see
> that it should ever be needed in platform configuration.  If the driver
> doesn't detect the MAC/PHY capabilities correctly then the driver should
> be fixed.  Overriding the settings once will not prevent an unsupported
> mode being selected later.

I'd suggest you have a look at the conversation that occurred in the 
thread which subject was "SMC91x: forcing speed", no later than 3 days 
ago.


Nicolas
