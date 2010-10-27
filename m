From: Nolan Leake <nolan@cumulusnetworks.com>
Subject: Re: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Tue, 26 Oct 2010 18:18:22 -0700
Message-ID: <1288142302.26640.7.camel@voxel>
References: <4CC2DB2C.3060908@xs4all.nl> <1287862760.7499.225.camel@voxel>
	 <4CC40398.6070105@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jim <jim876@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from phong.sigbus.net ([65.49.35.42]:59394 "EHLO phong.sigbus.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760633Ab0J0BSY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 21:18:24 -0400
In-Reply-To: <4CC40398.6070105@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-10-24 at 11:59 +0200, Jim wrote:
> Thanks for explaining the purpose of the patch.
> But it appears something is missing and I think it breaks current
> userspace. I use this tap0 device together with VirtualBox, I have a
> virtual machine setup as bridged to tap0, not a very odd or strange
> setup (this used to be the only method).
> On the host side I run dhcpd to hand out IP address to the virtual
> machine, but despite the dhcpd running on the tap0 device it never got
> 'ready' in the sense that no IP packets made it out from the host to the
> guest.

To make sure I understand the situation, is this correct (ignoring the
exact names of the interfaces):
br0 bridges between eth0 and tap0, and you run dhcpd on tap0?

Since tap0 is part of the bridge, I think dhcpd should be running on
br0.  Does that work?
