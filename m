From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 20:23:54 -0800
Message-ID: <20071201202354.672aed18@freepuppy.rosehill>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
	<20071201163035.321fd554@freepuppy.rosehill>
	<475227B1.2060802@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57178 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753519AbXLBEYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 23:24:44 -0500
In-Reply-To: <475227B1.2060802@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 01 Dec 2007 22:34:09 -0500
Mark Lord <lkml@rtr.ca> wrote:

> Stephen Hemminger wrote:
> > On Sat, 1 Dec 2007 11:17:36 -0800
> > Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > 
> >> Then init_net needs to be not GPL limited. Sorry, we need to allow
> >> non GPL network drivers.  There is a fine line between keeping the
> >> binary seething masses from accessing random kernel functions, and allowing
> >> reasonable (but still non GPL) things like ndiswrapper to use network
> >> device interface.
> >>
> > I spoke too soon earlier, ndiswrapper builds and loads against current
> > 2.6.24-rc3. Vmware and proprietary VPN software probably do not. Once again I don't
> > give a damn, but the enterprise distro vendors certainly care.
> ...
> 
> Naw, enterprise (or any other) distro vendors shouldn't have any issues here,
> since they can just patch their kernels around any issues.
> 
> But it looks like Eric has this one thought out well enough.

So you are saying all this is not a problem, fine.
Any affected parties can certainly lobby for themselves. But I suspect
they all think the kernel community is a bunch of ... and will just ignore
the problem. 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
