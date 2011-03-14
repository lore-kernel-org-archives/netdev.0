From: David Miller <davem@davemloft.net>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 15:22:55 -0700 (PDT)
Message-ID: <20110314.152255.68135182.davem@davemloft.net>
References: <1300131040.32696.23.camel@localhost.localdomain>
	<20110314.132355.226777213.davem@davemloft.net>
	<1300141060.32696.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, jeremy@goop.org,
	herbert@gondor.apana.org.au, konrad.wilk@oracle.com,
	romieu@fr.zoreil.com, shemminger@vyatta.com, mirqus@gmail.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46394
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932268Ab1CNWWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:22:17 -0400
In-Reply-To: <1300141060.32696.36.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 14 Mar 2011 22:17:40 +0000

> Would you consider a commit patch which imports the baseline driver as
> is from xen.git (this builds and is functional but needed clean up)
> followed by the cleanup series? I made sure the cleanup part builds and
> works at each step as I went (but I will run through it again to be
> sure).
> 
> There is real value (to me at least) in keeping the cleanup separate and
> being able to (even manually) associate the first upstream commit with
> an equivalent point in the historical code.

Do you have any idea what that thing is going to do for poor souls trying
to bisect?

GIT is going to hop in and out of your line of development for any GIT
bisect that traverses any period of time in which those driver commits
exists.

It's too messy.

You can keep your tree online somewhere to publish the history, just
like we do for the old bitkeeper import and similar.
