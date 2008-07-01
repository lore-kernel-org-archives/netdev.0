From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 1 Jul 2008 17:47:10 +0400
Message-ID: <20080701134709.GA14457@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <486A1AC7.9020706@trash.net> <20080701120320.GA9412@2ka.mipt.ru> <486A2487.2010303@trash.net> <486A31FF.8050201@garzik.org> <486A3286.9060100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <486A3286.9060100@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2008 at 03:35:02PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >It sure would be nice for regular socket applications to have an easy, 
> >unprivileged way to query the OS fingerprint information of a given 
> >socket.
> 
> I'm not sure how much OSF depends on the TTL, but doing this
> more than one hop away from the host (or without knowledge of
> the number of hops) makes using the TTL basically impossible.

There are three modes in OSF: LAN where things are simple, no-ttl, where
things are even more simpler and false positive, and heueristic mode,
which checks ttl, but with some addons. Like if ttl is 31, it is
possible that it is OS with initial TTL being equal to 32, and other OS,
with initial TTL 48, and whatever other checks succeeded for that cases,
determine what OS is.

It works quite good in internet not only LAN, since it is frequently
only enough to roughly determine initial TTL.

> >Another use case is validating whether a browser is "lying" about its 
> >OS, when parsing HTTP user-agent info, or in general when any remote 
> >agent is "lying" about its OS.  Security software can use that as an 
> >additional red-flag factor. 
> 
> I for one would be much happier to only have netfilter as a user
> of this :)

Security checkers do like to put its hands into sooo deep places in the stack :)

-- 
	Evgeniy Polyakov
