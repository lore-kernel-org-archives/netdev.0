From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX fix proposal
Date: 30 Jan 2005 22:38:00 -0500
Message-ID: <1107142680.7847.117.camel@jzny.localdomain>
References: <20050130181854.7f088a95.davem@davemloft.net>
	 <1107142423.8021.114.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1107142423.8021.114.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-30 at 22:33, jamal wrote:
> On Sun, 2005-01-30 at 21:18, David S. Miller wrote:
> > Ok, how about we do this for 2.6.11 before it goes out and
> > do something more sophisticated (if necessary) later.
> > 
> > The BUG() we're trying to catch in the ->hard_start_xmit()
> > routines is the illegal state:
> > 
> > 	driver_tx_queue_empty() && !netif_queue_stopped(dev)
> > 
> 
> In the e1000 theres a lot more code in hard_start_xmit() that could
> be possibly entered before you hit the xmit lock. So thats another
> potential issue.
> The tg3 you refer to in your email doesnt seem to be as bad and
> i am actually wondering why what you just posted is _the fix_ as is.

meant is not _the fix_
too many typos - off to bed.

cheers,
jamal
