From: alex@pilosoft.com
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 11:47:15 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0404221143340.2738-100000@paix.pilosoft.com>
References: <4087E7FB.7000400@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <4087E7FB.7000400@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Apr 2004, Chris Friesen wrote:

> alex@pilosoft.com wrote:
> 
> > Nevertheless, number of packets to kill the session is still *large*
> > (under "best-case" for attacker, you need to send 2^30 packets)...
> 
> I though the whole point of this vulnerability was that you "only"
> needed to send 64K packets, not 2^30.
64k packets if rwin is 64k and if you know ports on both sides.

If rwin is 16k (default on many routers) and you need to scan all
ephemeral ports, its 256k packets * number of ephemeral ports.

One router vendor has 4000 ephemeral ports maximum, resulting in 256k*4000 
= ~1 billion packets.


-alex
