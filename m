From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: 20 Dec 2004 09:13:46 -0500
Message-ID: <1103552026.1048.324.camel@jzny.localdomain>
References: <20041218170017.GH17998@postel.suug.ch>
	 <1103487827.1048.188.camel@jzny.localdomain>
	 <20041219203641.GL17998@postel.suug.ch>  <41C687EE.1090205@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41C687EE.1090205@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-20 at 03:06, Patrick McHardy wrote:

> You shouldn't care about IMQ, but we still need to copy the packet
> before modifying it if the data is shared. Otherwise we have a race
> on SMP with AF_PACKET sockets, depending on when the packet is read
> it can be either modified or not.

Certainly not a big deal; shouldnt care if once in a while tcpdump
actually gets to see the real packet that went out the wire.

> Converting dsmark to an action sounds like the best long-term solution.

Indeed; hence my comment to talk to Werner.

cheers,
jamal
