From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 12:53:14 +0100
Message-ID: <20130106115314.GA16031@1wt.eu>
References: <1357435276.1678.5067.camel@edumazet-glaptop> <20130106013027.GV16031@1wt.eu> <1357436430.1678.5111.camel@edumazet-glaptop> <1357437086.1678.5135.camel@edumazet-glaptop> <1357438591.1678.5205.camel@edumazet-glaptop> <20130106025256.GY16031@1wt.eu> <1357457724.1678.5941.camel@edumazet-glaptop> <20130106092435.GZ16031@1wt.eu> <20130106102525.GA22151@1wt.eu> <87wqvqlej1.fsf@silenus.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Romain Francoise <romain@orebokech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87wqvqlej1.fsf@silenus.orebokech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 06, 2013 at 12:46:58PM +0100, Romain Francoise wrote:
> Willy Tarreau <w@1wt.eu> writes:
> 
> > That makes me think that I should try 3.8-rc2 since LRO was removed
> > there :-/
> 
> Better yet, find a way to automate these tests so they can run continually
> against net-next and find problems early...

There is no way scripts will plug cables and turn on sleeping hardware
unfortunately. I'm already following network updates closely enough to
spot occasional regressions that are naturally expected due to the number
of changes.

Also, automated tests won't easily report a behaviour analysis, and
behaviour is important in networking. You don't want to accept 100ms
pauses all the time for example (and that's just an example).

Right now my lab is simplified enough so that I can test something like
100 patches in a week-end, I think that's already fine.

Willy
