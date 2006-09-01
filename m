From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] zd1211rw: Removed unneeded packed attributes
Date: Fri, 1 Sep 2006 21:41:26 +0200
Message-ID: <20060901194126.GA10285@p15091797.pureserver.info>
References: <20060829225143.AD4637B40A0@zog.reactivated.net> <200608301506.03296.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:16093 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751320AbWIATl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 15:41:27 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608301506.03296.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-30 15:06 Michael Buesch wrote:

> Because this clearly is a workaround for broken compilers to me,
> I would rather do the following:
> 
> +} /* __attribute__((packed)) */;
> 
> 
> This way it's still clear to the reader, that these structs
> must be packed and are most likely for communication with
> the hardware.

I'm not so sure, whether the compilers are broken. On platforms
like SPARC and IA-64 that don't support unaligned memory access
the compiler has to create slow code for each packed field access.
If the compiler would create fast code for accessing packed fields
that are actually aligned inside the struct, it would break code
that access the struct at unaligned locations. You could say these
guys are relying on undefined behaviour but I would like to see
how the SPARC folks would react, when gcc would break old code.

Ciao,

Uli

-- 
Uli Kunitz
