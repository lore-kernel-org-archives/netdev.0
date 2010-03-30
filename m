From: Jasen Betts <Jasen@treshna.com>
Subject: Re: [Bugme-new] [Bug 15571] New: TCP madness - some packets are
	shunned.
Date: Wed, 31 Mar 2010 10:08:12 +1300
Message-ID: <20100330210812.GA31047@treshna.com>
References: <bug-15571-10286@http.bugzilla.kernel.org/> <20100322143711.b78c7a93.akpm@linux-foundation.org> <4BAB8281.8000905@nets.rwth-aachen.de> <20100326053151.GA23938@treshna.com> <4BAC733A.1070403@nets.rwth-aachen.de> <20100327212644.4bfda1ac@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from treshna.com ([210.48.71.196]:39159 "EHLO tyreal.treshna.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab0C3V2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:28:09 -0400
Content-Disposition: inline
In-Reply-To: <20100327212644.4bfda1ac@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 27, 2010 at 09:26:44PM -0700, Stephen Hemminger wrote:
> 
> The window is also settable on a per route basis as well.
> 
> http://lwn.net/Articles/92727/
 
 Have used this on our squid proxy server, all is good now.
 thanks.

 ip route add 121.199.32.220  via  upstream.ip.router.addr  window 65535

