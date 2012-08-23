From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 1/1] tcp: Wrong timeout for SYN segments
Date: Thu, 23 Aug 2012 14:51:23 +0200
Message-ID: <1345726283.5904.842.camel@edumazet-glaptop>
References: <503419D3.1080700@linlab.net>
	 <CAFbMe2M7ekc94bQk7vTS1LhScPd49VZ-zKOCUXhqwxXtL-nkuA@mail.gmail.com>
	 <50361AEA.6010807@linlab.net> <1345724123.5904.756.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6FC3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Bergmann <alex@linlab.net>,
	"H.K. Jerry Chu" <hkjerry.chu@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC3@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-23 at 13:35 +0100, David Laight wrote:
> > I would suggest to increase TCP_SYN_RETRIES from 5 to 6.
> > 
> > 180 secs is eternity, but 31 secs is too small.
> 
> Wasn't the intention of the long delay to allow a system
> acting as a router to reboot?
> I suspect that is why it (and some other TCP timers)
> are in minutes.

One could argue that if an application really wants to connect to a
peer, it should probably handle failures and retries.

But for unaware (basic ?) applications, the 3 -> 1 change reduced by a 3
factor the timeout. So a transient network failure has now more
chance to impact them.

Not all applications run inside a browser or under human control...
