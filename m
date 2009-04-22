From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Add new cs89x0 driver
Date: Thu, 23 Apr 2009 00:53:28 +0200
Message-ID: <20090422225328.GA14729@mail.wantstofly.org>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:41434 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbZDVWwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 18:52:36 -0400
Content-Disposition: inline
In-Reply-To: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 09:59:30AM +0200, Sascha Hauer wrote:

> While this is a very old chip it is still in use on some embedded
> boards.  I see myself unable to fix the in Kernel driver to bring
> it to driver model support, so this patch adds a new driver designed
> to replace the old one, at least for non-ISA hardware.

I had the same thought initially when I started working on mv643xx_eth,
but I decided to try and beat the existing driver into shape anyway.  The
mv643xx_eth driver now is not too different from how I would have written
it had I rewritten it from scratch, and refactoring it took about a
hundred commits and probably a bunch more effort than just rewriting it
would have taken, but in the end I probably _saved_ myself time by being
able to (have users) bisect problems instead of having to spend time
trying to figure out why driver A works but B doesn't or vice versa, not
having to chase people to switch their platforms over to the new driver,
etc.

(I'm not saying that there's absolutely no other way for you to go than
to do the same thing -- it's just a thought.)
