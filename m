From: David Lamparter <equinox@diac24.net>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Thu, 24 Mar 2011 17:25:26 +0100
Message-ID: <20110324162526.GB3452309@jupiter.n2.diac24.net>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org>
 <20110208.134421.39185637.davem@davemloft.net>
 <4D51BFCE.2070405@msgid.danisch.de>
 <20110208.143046.246534138.davem@davemloft.net>
 <20110208224411.GA9674@electric-eye.fr.zoreil.com>
 <20110208234753.48abd902.billfink@mindspring.com>
 <20110209074221.GA9790@electric-eye.fr.zoreil.com>
 <4D8B5E1E.6060608@msgid.danisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Hadmut Danisch <hadmut@danisch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52934 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162Ab1CXQZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 12:25:39 -0400
Content-Disposition: inline
In-Reply-To: <4D8B5E1E.6060608@msgid.danisch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 04:07:10PM +0100, Hadmut Danisch wrote:
> How would I configure a Linux machine to accept ipv6 prefix ads (because
> they are dynamically assigned and advertised by my router) and to work
> as a VPN tunnel end?
> 
> 
> Remember: Linux does not allow autoconfiguration and routing at the same
> time, without any good reason.

You seem to have arrived at a bit of a misunderstanding here. Linux does
not forbid autoconfiguration when you enable routing. It just disables
the in-kernel code, for reasons that usually are well-founded.

> If you believe that Linux is correct here the way it is, just tell me
> how to solve that problem with Linux.

You grab rdisc6 from the ndisc6 package (http://www.remlab.net/ndisc6/,
probably packaged by your distro) and do the autoconfiguration in user
space.

The userspace application will also give you an amount of control over
the autoconfiguration that is IMHO neccessary if you use it this way and
which the kernel cannot provide.


-David

