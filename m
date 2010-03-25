From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Question about e06e7c615877026544ad7f8b309d1a3706410383 --
 [IPV4]: The scheduled removal of multipath cached routing support.
Date: Thu, 25 Mar 2010 13:21:37 -0400
Message-ID: <20100325172137.GA12751@elliptictech.com>
References: <2d460de71003251011y2d8d1931u683b396f40df4ed1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@sunset.davemloft.net
To: Richard Hartmann <richih.mailinglist@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2d460de71003251011y2d8d1931u683b396f40df4ed1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18:11 Thu 25 Mar     , Richard Hartmann wrote:
> I was wondering what the rationale for commit
> e06e7c615877026544ad7f8b309d1a3706410383 is. We upgraded our custom
> image to 2.6.33 recently and found those options to be missing.

>From the diff of that commit:

-What:	Multipath cached routing support in ipv4
-When:	in 2.6.23
-Why:	Code was merged, then submitter immediately disappeared leaving
-	us with no maintainer and lots of bugs.  The code should not have
-	been merged in the first place, and many aspects of it's
-	implementation are blocking more critical core networking
-	development.  It's marked EXPERIMENTAL and no distribution
-	enables it because it cause obscure crashes due to unfixable bugs
-	(interfaces don't return errors so memory allocation can't be
-	handled, calling contexts of these interfaces make handling
-	errors impossible too because they get called after we've
-	totally commited to creating a route object, for example).
-	This problem has existed for years and no forward progress
-	has ever been made, and nobody steps up to try and salvage
-	this code, so we're going to finally just get rid of it.
-Who:	David S. Miller <davem@davemloft.net>

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
