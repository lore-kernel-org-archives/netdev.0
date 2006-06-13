From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [2.6.17-rc6] Section mismatch in drivers/net/ne.o during modpost
Date: Tue, 13 Jun 2006 22:38:28 +0200
Message-ID: <20060613203828.GA26690@mars.ravnborg.org>
References: <200606110051.k5B0pLBI010621@harpo.it.uu.se> <10735.1150176929@kao2.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikael Pettersson <mikpe@it.uu.se>, rdunlap@xenotime.net,
	akpm@osdl.org, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:26563 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S932229AbWFMUjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 16:39:00 -0400
To: Keith Owens <kaos@ocs.com.au>
Content-Disposition: inline
In-Reply-To: <10735.1150176929@kao2.melbourne.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Probably over enthusiastic gcc inlining.  gcc 4 will inline functions
> that are not declared as inline.  That is not so bad, except that some
> versions of gcc will ignore a mismatch in function attributes and
> inline a __init function into normal text, generating additional
> section mismatches.
When using -ffunction-sections (or similar) then we ask gcc to put each
function in separate sections. In this case it is OK to mix sections.
But I agree, gcc should not mix user specified sections.

> For a specific example, see
> 
> http://marc.theaimsgroup.com/?l=linux-kernel&m=113824309203482&w=2
That's a good example - thanks!

	Sam
