From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Thu, 17 Feb 2005 15:11:22 -0800
Message-ID: <20050217151122.098c6def.davem@davemloft.net>
References: <4214381F.5020507@trash.net>
	<20050217113654.GA10346@gondor.apana.org.au>
	<4214DF5B.3010608@trash.net>
	<20050217203805.GA4047@gondor.apana.org.au>
	<42150B36.5080609@trash.net>
	<20050217221031.GA4554@gondor.apana.org.au>
	<42152283.4030800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42152283.4030800@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Feb 2005 00:02:27 +0100
Patrick McHardy <kaber@trash.net> wrote:

> >Well we'll have to disagree on that.  IMHO the flow with the internal
> >addresses equal to the external addresses over a tunnel mode SA should
> >be treated the same as that over a transport mode SA.
> 
> Maybe Dave can help resolve this with a third opinion.

I have to side with Patrick on this one.

This is one of the fundamental tunnel behavior differences between
Transport mode and Tunnel mode SAs.
