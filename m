From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Sun, 19 Dec 2004 21:36:41 +0100
Message-ID: <20041219203641.GL17998@postel.suug.ch>
References: <20041218170017.GH17998@postel.suug.ch> <1103487827.1048.188.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103487827.1048.188.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103487827.1048.188.camel@jzny.localdomain> 2004-12-19 15:23
> If the qdisc at that level muddies the packet thats fair game - thats
> what goes out on the wire. So we should leave the code as is.

Agreed for egress but I think it is needed for stuff like IMQ. It's
debatable whether we should take care of IMQ and alike though.
