From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 19 Aug 2003 13:35:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>,
   Stephan von Krawczynski <skraw@ithnet.com>, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, Marcelo Tosatti <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2003-08-19 at 13:02, Richard Underwood wrote:
> 	ARP is local to a broadcast net. The ARP standard explicitly
> prohibits responding to an ARP request on a different interface.

Correct, but we don't do that

> 	If you broadcast a request asking for a reply on an entirely
> different subnet, you're asking for trouble. You REDUCE the likelyhood of a
> successful ARP reply, not increase it.

You increase it and you shortcut on shared lans. Thats really a seperate
issue to the question of which source is used. If you loopback someone
elses address on your own lo device I'm not suprised weird shit happens,
put the alias on eth0 where it belongs.

> 	All you can possibly achieve by sending REQUESTS from the wrong IP
> number is assist screwed up networks where you've got multiple subnets on
> the same copper and cause a shed-load of security issues.

Not in general. If you are using ARP your lan is hardly "secure". For
most situations the trust across multiple aggregated lans is the same,
if it isnt people use vlan (which rarely helps 8))
