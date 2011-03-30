From: Geert Hendrickx <geert@hendrickx.be>
Subject: Re: [Bugme-new] [Bug 28512] New: IPv6 SLAAC address preferred over
 static one as source address
Date: Wed, 30 Mar 2011 09:31:39 +0200
Message-ID: <20110330073139.GA8190@boris.ghen.be>
References: <bug-28512-10286@https.bugzilla.kernel.org/>
 <20110207152048.22c51184.akpm@linux-foundation.org>
 <20110329.172000.102543782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brigitte.telenet-ops.be ([195.130.137.66]:58259 "EHLO
	brigitte.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab1C3Hbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 03:31:46 -0400
Content-Disposition: inline
In-Reply-To: <20110329.172000.102543782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 17:20:00 -0700, David Miller wrote:
> This is debatable.
> 
> One could just as easily say that an address with a shorter preferred
> lifetime has been revalidated more recently, and therefore is more
> likely to be uptodate, valid, and lead to a usable path.


There we're at "most recent" again.  In practice, this will often be a SLAAC
address, which will rarely be preferred over a staticly configured one.



> I think the lack of specification for the final tie-breaker in the RFC
> was intentional :-)
> 
> The specification has to address this, and until the situation is more
> clear cut than it is now I don't see any benefit for changing Linux's
> behavior.  Especially since there is a configuration based workaround
> which works for people in the short-term.


What workaround are you referring to?


	Geert


-- 
geert.hendrickx.be :: geert@hendrickx.be :: PGP: 0xC4BB9E9F
This e-mail was composed using 100% recycled spam messages!
