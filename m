From: Dave Dillow <dave@thedillows.org>
Subject: Re: IPsec performance
Date: Tue, 03 May 2005 15:27:41 -0400
Message-ID: <1115148461.31573.9.camel@dillow.idleaire.com>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
	 <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
	 <Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
	 <Pine.GSO.4.58.0505030820160.24686@kekkonen.cs.hut.fi>
	 <1115099678.2953.3.camel@ori.thedillows.org>
	 <Pine.GSO.4.58.0505030943310.247@kekkonen.cs.hut.fi>
	 <1115129839.2953.4.camel@ori.thedillows.org>
	 <Pine.GSO.4.58.0505031913020.9502@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Miika Komu <miika@iki.fi>
In-Reply-To: <Pine.GSO.4.58.0505031913020.9502@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-03 at 19:14 +0300, Miika Komu wrote:
> On Tue, 3 May 2005, Dave Dillow wrote:
> > 3DES is processor intensive. I'd say 1.9MB/s is reasonable for the
> > hardware you are on.
> 
> Ok. Thanks for your quick responses!

I should note that I mean reasonable given the current implementation --
you're seeing performance in line with numbers on other machines. I
think it's been mentioned that our 3DES implementation has not been
tuned for x86, so there's probably some performance being left on the
floor. I could be wrong, though.
-- 
Dave Dillow <dave@thedillows.org>
