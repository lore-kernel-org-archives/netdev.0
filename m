From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Thu, 29 Mar 2007 13:18:01 +0400
Message-ID: <20070329091801.GA17268@2ka.mipt.ru>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <p73lkhi6aj7.fsf@bingen.suse.de> <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON> <200703281129.43783.ak@suse.de> <20070328104505.GA18748@2ka.mipt.ru> <p73y7lh316u.fsf@bingen.suse.de> <20070328155047.4112fb47.dada1@cosmosbay.com> <20070328145255.GA7466@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>, nikb@webmaster.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34168 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbXC2JTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 05:19:33 -0400
Content-Disposition: inline
In-Reply-To: <20070328145255.GA7466@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 04:52:55PM +0200, Andi Kleen (andi@firstfloor.org) wrote:
> > 3) We dont want to be 'totally secure'. We only want to raise the level, and eventually see if we have to spend more time on this next year(s). AFAIK we had two different reports from people being hit by the flaw of previous hash. Not really a critical issue.
> 
> Yes, but you probably want a complexity of at least 10^5-10^6 to be any
> useful. I don't think you will get that early in boot from random
> unless you use hardware support.

What we have (had) right now is broken situation, and it must be fixed
no matter what solution is used. Using more secure hash (and breaking
Jenkins hash is a bit harder than XOR one, I say it not only from
theoretical point of view looking into its operations) is a fix.
It is possible that there is even better fix - there is always something
better than one has right now, but right now problem must be fixed.
And David (and Eric, and Nikolaos) fixed that problem in place.
It can be solved (this time it will be called 'improved') further.

> > 
> > 4) We could add a hard limit on the length of one chain. Even if the bad guys discover a flaw, it wont hurt too much.

Hard limit should not be used, since it is exactly what attacker wants -
attacker can get all slots in th hash table and server will not respond
to other clients at all, although it could, but much slower.

> Or just use the trie?  It has other advantages too :)

As an interested party I should not comment, but I can not resist - 
yes, it is cool and can be done better :)

> -Andi

-- 
	Evgeniy Polyakov
