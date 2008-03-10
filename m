From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] Shrink syncookie_secret by 8 byte.
Date: Mon, 10 Mar 2008 19:07:07 +0100
Message-ID: <20080310180707.GK31123@Chamillionaire.breakpoint.cc>
References: <1205164157-26681-1-git-send-email-fw@strlen.de> <47d57829.4301360a.7970.ffffb769@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:43536 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbYCJSHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 14:07:08 -0400
Content-Disposition: inline
In-Reply-To: <47d57829.4301360a.7970.ffffb769@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glenn Griffin <ggriffin.kernel@gmail.com> wrote:
> You are correct.  syncookie_secret was declared static before ipv6 support was
> added, and shrinking it by 4 bytes wont have any effect on ipv6.
> 
> You forgot to change the declaration in net/ipv6/syncookies.c.  Here is
> an amended patch to include that.

Oops. Thanks for reviewing and fixing this up!
