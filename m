From: bert hubert <ahu@ds9a.nl>
Subject: Re: unregister_netdev Annoyance WAS(Re: ing_filter debug messages
Date: Sun, 2 Jan 2005 13:13:49 +0100
Message-ID: <20050102121349.GA27022@outpost.ds9a.nl>
References: <20041230160643.GD24603@wiggy.net> <1104469666.1049.231.camel@jzny.localdomain> <20041231093827.GG24603@wiggy.net> <1104491510.1047.234.camel@jzny.localdomain> <20041231131553.GA7460@wiggy.net> <1104505838.1048.273.camel@jzny.localdomain> <20041231154844.GA11511@wiggy.net> <1104511697.1048.308.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104511697.1048.308.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > However, the unregister_netdev problem still persists.
> 
> I am pretty sure its a different problem. Quick scan shows the
> register/unregister state machine may be at fault. 

This is a separate and known problem - see 'Re: Major deadlock:
unregister_netdevice: waiting for <device> to become free. Usage count = 1'
by Peter Bieringer.

For some reason this issue has been widely ignored. I see it as well here
and it is the one reason I don't entirely trust 2.6.10 yet in production.

Thanks for looking into it Jamal!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
