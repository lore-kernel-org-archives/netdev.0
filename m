From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 09:04:58 +0100
Message-ID: <20070220080457.GA20544@outpost.ds9a.nl>
References: <20070219231447.GA4400@outpost.ds9a.nl> <20070219155623.1d78785a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:57014 "EHLO outpost.ds9a.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964952AbXBTIFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 03:05:00 -0500
Content-Disposition: inline
In-Reply-To: <20070219155623.1d78785a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 03:56:23PM -0800, Stephen Hemminger wrote:

> > Linux 2.6.20-rc4 appears to take 4 microseconds on my P4 3GHz for a
> > non-blocking UDPv4 recvfrom() call, both on loopback and ethernet.
> > 
> > Linux 2.6.18 on my 64 bit Athlon64 3200+ takes a similar amount of time.

> > recvfrom itself is a tad worrisome, x=recvfrom. I didn't ask for the
> > 'libc_enable_asynccancel' stuff. I'm trying to isolate the actual syscall
> > but it is proving hard work for an assemnly newbie like me - socketcall
> > doesn't make things easier.

Together with Zwane Mwaikambo, we managed to isolate the pure syscall, it
doesn't make a difference, a single recvfrom continues to take around 4
microseconds at 3GHz. Many thanks to Zwane for helping out.

> Use oprofile to find the hotspot.

Will do this next - I need to get me a setup where I can do oprofile *and*
decent query rates, I don't do oprofile on my remote machines I don't have
easy access to.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
