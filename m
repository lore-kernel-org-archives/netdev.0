From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sun, 2 Dec 2007 13:51:04 +0000
Message-ID: <20071202135104.006c5a15@the-village.bc.nu>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:33830 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752952AbXLBNzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 08:55:15 -0500
In-Reply-To: <20071201163035.321fd554@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Dec 2007 16:30:35 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On Sat, 1 Dec 2007 11:17:36 -0800
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> > Then init_net needs to be not GPL limited. Sorry, we need to allow
> > non GPL network drivers.  There is a fine line between keeping the
> > binary seething masses from accessing random kernel functions, and allowing
> > reasonable (but still non GPL) things like ndiswrapper to use network
> > device interface.
> > 
> I spoke too soon earlier, ndiswrapper builds and loads against current
> 2.6.24-rc3. Vmware and proprietary VPN software probably do not. Once again I don't
> give a damn, but the enterprise distro vendors certainly care.

Enterprise distro vendors ship kernels from the 2.6.19 era, so I don't
see why they care.

Alan
