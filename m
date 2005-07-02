From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: controlling ARP Proxy scope?
Date: Sat, 2 Jul 2005 23:21:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507022316310.26953__17795.5516418026$1120339918$gmane$org@filer.marasystems.com>
References: <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <3u3gb7$1mhk2i@smtp05.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Jul 2005, Zdenek Radouch wrote:

> So, left with only a binary flag in /proc,  and network definition on the
> interface,
> I assumed (perhaps naively) that the arp would proxy only for the addresses
> within the subnet defined for the interface (on which the proxy arp is
> turned on).
> However, that does not seem to be the case.

You may be able to tune this with either arp_filter or arp_ignore.

> I have an interface with address 10.1.2.219 and mask 255.255.255.248 with
> proxy arp turned on on this interface, and the machine is responding
> (I see that with tcpdump) to arp requests for address 10.1.2.1, i.e.,
> an address outside of the proxy interface's subnet.

Correct.

> Can anyone explain the behavior?

proxy_arp simply ARPs if there is a route for the requested destination 
going out on another interface than where the ARP was seen.

Regards
Henrik
