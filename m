From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Provide ability to change default netdev name?
Date: Sat, 17 Aug 2013 01:41:08 +0200
Message-ID: <1376696468.11042.74.camel@deadeye.wl.decadent.org.uk>
References: <520EA43F.2010304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44897 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706Ab3HPX7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 19:59:32 -0400
In-Reply-To: <520EA43F.2010304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-16 at 15:14 -0700, Ben Greear wrote:
> The latest udev in Fedora 19 (and perhaps elsewhere) will no longer
> implement rules that rename an interface from ethX to ethY.  Nor
> wlanX or other 'kernel namespaces'.  The Fedora udev developers do not seem
> interested in changing this back to the old behaviour, evidently they
> had a hard time implementing it properly.

There is an inherent problem that a new device can appear at any time
under the exact name udev is trying to rename to.  I expect it is
possible to do this properly but may be quite difficult to eliminate the
possibility of deadlock.

Still, if udev actively refuses to use the 'kernel namespaces' (rather
than just being configured not to), that would be a bug.

> This effectively makes it impossible to have network device names of ethX
> consistent across reboots in systems with multiple NICs and/or drivers.
> 
> One way to work around this would be allow the kernel to use a different
> default netdev name (for instance, keth%d).  I'm thinking this would be
> configured as a kernel command line argument.  Then, a small change to udev/systemd to
> make the 'kernel namespaces' configurable by letting it understand this new kernel
> command line argument should resolve the problem.
> 
> Does this sound like something that could be accepted upstream?

This sounds completely ridiculous.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
