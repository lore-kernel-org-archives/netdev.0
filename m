From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How does Linux do RTTM?
Date: Sat, 12 Aug 2006 17:53:32 +0400
Message-ID: <20060812135332.GA27390@2ka.mipt.ru>
References: <44DACA22.6090701@comcast.net> <20060809.231244.35509467.davem@davemloft.net> <44DAF559.8010705@comcast.net> <20060810.020205.10245646.davem@davemloft.net> <44DDD83E.9010307@comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932516AbWHLNyG@vger.kernel.org>
To: John Richard Moser <nigelenki@comcast.net>
Content-Disposition: inline
In-Reply-To: <44DDD83E.9010307@comcast.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 09:31:42AM -0400, John Richard Moser (nigelenki@comcast.net) wrote:
> I'm told now that it uses Jiffies for TCP timestamps.  I've had thoughts
> on this:
> 
>  - I figured a random timestamp with random microsecond skew would be
> nice but this might expose internals of the RNG; amusingly I'm trying
> not to expose internals of the RNG by exposing system time.
> 
>  - Someone recommended starting at zero.  This would work, really,
> there's no attacks based on guessing the TCP timestamp value.  This is
> nice since if I want to hax0rz then I might make a connection and see
> how many jiffies there are to get a feel for the system's uptime; this
> tells me how long since you upgraded your kernel, so I have an arsenal
> of vulns I KNOW you haven't fixed ready ;)  Starting at 0 doesn't give
> that information.
> 
> Comments?

Starting TCP timestamp from zero or any other arbitrary value for each 
new connection will not give you any security benefits. There is no 
simple way aleph1 or e-eye will get a remote shell or steal your credit 
card number if there is a buffer overflow in kernel and they will know 
it's release.
So your proposals just are not needed for majority of people, but if you
strongly feel it will help to find a cure for cancer, implement it and
prove it's usefullness to netdev community.

-- 
	Evgeniy Polyakov
