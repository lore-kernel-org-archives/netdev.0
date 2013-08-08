From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 0/5] netfilter: implement netfilter SYN proxy
Date: Thu, 8 Aug 2013 02:13:45 +0200
Message-ID: <20130808001344.GA24450@macbook.localnet>
References: <1375898766.4004.37.camel@edumazet-glaptop>
 <20130807205959.GC21463@macbook.localnet>
 <20130807210540.GE32257@order.stressinduktion.org>
 <20130807.164056.2110811182336568861.davem@davemloft.net>
 <20130808000412.GF32257@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130808000412.GF32257@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 08, 2013 at 02:04:12AM +0200, Hannes Frederic Sowa wrote:
> On Wed, Aug 07, 2013 at 04:40:56PM -0700, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Wed, 7 Aug 2013 23:05:40 +0200
> > 
> > > It seems, Windows stopped using tcp timestamps at least in windows 8 by
> > > default.
> > 
> > Thankfully, Android device outnumber Windows 8 installs
> > by... something like 1,000 to 1, right?
> 
> Heh, at minimum. :)
> 
> > I throw a huge "doesn't matter" to whatever Windows's TCP stack
> > decides to do.  It absolutely should not dictate whether we decide to
> > make use of this or that feature of TCP.  It's a bit player at best.
> > 
> > So if Windows 8 is the reason you're saying we shouldn't use
> > timestamps for anything, you're wrong.
> 
> Actually, I don't care at all, because I don't do anything with windows
> and don't get paid by anyone who wants me to care. ;)
> 
> But if we switch to a similar scheme as freebsd we can even care
> less because even if some other operating systems or a major provider
> decides to disable timestamps on their devices, we would still have
> window scaling, sack (and ecn?) under syn dos. So, I do think it is an
> improvement and don't see any disadvantages.
> 
> So, I don't care as long as the change (and siphash or maybe another
> hashing scheme) is secure enough...

So maybe lets agree to this - we all don't care about Windows 8, but
more importantly, I'd prefer to do one thing at a time and cryptographic
hashing isn't exactly my area of expertise. So lets get these patches
in order and after that I'll look into making SYN cookies perform better
for the poor souls using Windows 8, if that's possible without using
timestamps ;)
