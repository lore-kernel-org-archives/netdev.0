From: Martin Mares <mj@ucw.cz>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Sun, 6 Mar 2005 10:56:42 +0100
Message-ID: <20050306095642.GA1352@ucw.cz>
References: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
Content-Disposition: inline
In-Reply-To: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Unfortunately, this does not work with the Linux stack, because the
> 127 net is treated (for good reasons I suppose) as a special net.

Is it really?

I've just tried

	ip addr del 127.0.0.1/8 dev lo
	ip addr add 127.0.0.1/24 dev lo

and `ping 127.1.2.3' is then happily sent along the default route.

				Have a nice fortnight
-- 
Martin `MJ' Mares   <mj@ucw.cz>   http://atrey.karlin.mff.cuni.cz/~mj/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
Only dead fish swim with the stream.
