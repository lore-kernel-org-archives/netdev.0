From: bert hubert <ahu@ds9a.nl>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it to another host
Date: Mon, 7 Mar 2005 22:32:11 +0100
Message-ID: <20050307213211.GA25323@outpost.ds9a.nl>
References: <20050306153108.20430b58.random@72616e646f6d20323030342d30342d31360a.nosense.org> <1110199198.1094.1282.camel@jzny.localdomain> <20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Content-Disposition: inline
In-Reply-To: <20050308002643.7eac84e7.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 08, 2005 at 12:26:43AM +1030, Mark Smith wrote:

> (Bert, sorry for calling you Ben earlier, I must have got a bit
> distracted between seeing your name on a web page, and typing it on my
> email client)

I'll live :-) there are several Ben's I'd love to be confused with :-)

> I'm fairly confident that broadly I'm thinking about the same way as
> Bert, although as I'm about to go into some detail, it might turn out we
> have slightly different ideas.

Indeed, we are in full agreement. The idea is to have the ability to fully
firewall and monitor a machine that absolutely needs to have a real
routable IP address, without wasting an IP address for the router (or trying
to get an ISP to assign you multiple addresses, which can be a major chore
these days).

I'd settle for a 'dirty' solution. Remco van Mook of Virtu.nl suggested
abusing iptables -j QUEUE combind with tun/tap to inject the packets on the
ethernet side, where userspace does the PPP -> ethernet conversion by making
up the required headers.

Ideas?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
