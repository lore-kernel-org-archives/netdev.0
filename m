From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 11:29:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819112912.359eaea6.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
	<1061296544.30566.8.camel@dhcp23.swansea.linux.org.uk>
	<1061317825.3744.7.camel@athena.fprintf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, richard@aspectgroup.co.uk, skraw@ithnet.com,
   willy@w.ods.org, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, bloemsaa@xs4all.nl, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Gryniewicz <dang@fprintf.net>
In-Reply-To: <1061317825.3744.7.camel@athena.fprintf.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Aug 2003 14:30:26 -0400
Daniel Gryniewicz <dang@fprintf.net> wrote:

> If you are not on a shared lan, then it will *ONLY* work if linux is
> on the other end.  No other system will work.

And these other systems are broken.  (actually, older Cisco equipment
correctly responds to the ARP regardless of source IP)

Just because some Cisco engineer says that it is correct doesn't
make it is.

Consider the situation logically.  When you're replying to an
ARP, _HOW_ do you know what IP addresses are assigned to _MY_
outgoing interfaces and _HOW_ do you know what subnets _EXIST_
on the LAN?

The answer to both is, you'd don't know these things _EVEN_ if
you are a router/gateway.

Therefore there is no valid reason not to respond to an ARP using one
source address as opposed to another.
