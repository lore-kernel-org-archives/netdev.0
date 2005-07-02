From: Zdenek Radouch <zdenek@rcn.com>
Subject: controlling ARP Proxy scope?
Date: Fri, 01 Jul 2005 22:16:13 -0400
Message-ID: <3u3gb7$1mhk2i__37496.8047989116$1120270931$gmane$org@smtp05.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I haven't been able to locate anything discussing how to control the scope
of Linux proxy ARP.

So, left with only a binary flag in /proc,  and network definition on the
interface,
I assumed (perhaps naively) that the arp would proxy only for the addresses
within the subnet defined for the interface (on which the proxy arp is
turned on).
However, that does not seem to be the case.

I have an interface with address 10.1.2.219 and mask 255.255.255.248 with
proxy arp turned on on this interface, and the machine is responding
(I see that with tcpdump) to arp requests for address 10.1.2.1, i.e.,
an address outside of the proxy interface's subnet.

Can anyone explain the behavior?
What is the scope of the proxying?
If the scope is not limited to the proxy interface's subnet, then how do I
avoid proxying
for addresses of machines facing the proxy server?  This seems to be quite
broken.

I am running 2.4.25 kernel.

I'll appreciate any pointers.  Thanks!
-Zdenek
