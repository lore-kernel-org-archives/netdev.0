From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: 19 Dec 2004 17:53:41 -0500
Message-ID: <1103496820.1049.204.camel@jzny.localdomain>
References: <20041218170017.GH17998@postel.suug.ch>
	 <1103487827.1048.188.camel@jzny.localdomain>
	 <20041219203641.GL17998@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041219203641.GL17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-19 at 15:36, Thomas Graf wrote:
> * jamal <1103487827.1048.188.camel@jzny.localdomain> 2004-12-19 15:23
> > If the qdisc at that level muddies the packet thats fair game - thats
> > what goes out on the wire. So we should leave the code as is.
> 
> Agreed for egress but I think it is needed for stuff like IMQ. It's
> debatable whether we should take care of IMQ and alike though.

You are right, it may cause an issue on an IMQ like device when we have
one in kernel. Hang on to the patch for now is my opinion; "schedulers"
should probably not be mucking with packets once they are queued in
(dsmark aint really a scheduler). We should talk to Werner to see if we
can move that functionality prequeueing ...

cheers,
jamal
