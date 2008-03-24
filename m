From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Shrink syncookie_secret by 8 byte.
Date: Sun, 23 Mar 2008 22:21:45 -0700 (PDT)
Message-ID: <20080323.222145.191861145.davem@davemloft.net>
References: <1205164157-26681-1-git-send-email-fw@strlen.de>
	<47d57829.4301360a.7970.ffffb769@mx.google.com>
	<20080310180707.GK31123@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ggriffin.kernel@gmail.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752077AbYCXFVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:21:46 -0400
In-Reply-To: <20080310180707.GK31123@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 10 Mar 2008 19:07:07 +0100

> Glenn Griffin <ggriffin.kernel@gmail.com> wrote:
> > You are correct.  syncookie_secret was declared static before ipv6 support was
> > added, and shrinking it by 4 bytes wont have any effect on ipv6.
> > 
> > You forgot to change the declaration in net/ipv6/syncookies.c.  Here is
> > an amended patch to include that.
> 
> Oops. Thanks for reviewing and fixing this up!

Applied to net-2.6.26, thanks everyone.
