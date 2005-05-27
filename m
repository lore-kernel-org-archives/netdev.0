From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 11:01:31 -0400
Message-ID: <1117206091.6383.73.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050527125010.GO15391@postel.suug.ch>
	 <1117202331.6383.39.camel@localhost.localdomain>
	 <20050527141320.GQ15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050527141320.GQ15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 16:13 +0200, Thomas Graf wrote:

> That is what the patch does but the diff looks a bit irritating.
> 1) Introduce NLMSG_NEW to take flags
> 2) Make NLMSG_PUT call NLMSG_NEW with flags==0
> 3) Change __nlmsg_put to take flags argument
> 

Yikes - sorry i glossed over the patch.

> > The first change would be definetely on top of the current patch i sent
> > which is well deserved.
> > Lets have Dave swallow my patch then either you or i could make those
> > changes. Sounds reasonable?
> 
> Sure.


Dave please apply the patch i posted into your tree and then we can
follow with this other stuff. 
Actually Thomas, you can probably apply my patch on your side and then
the other changes to use _NEW() on top of it. If you dont have time i
could do it tommorow.

cheers,
jamal
