From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 16:55:58 +0100
Message-ID: <20080205155558.GA23145@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>
To: Glenn Griffin <ggriffin.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47745 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbYBEPVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 10:21:07 -0500
Content-Disposition: inline
In-Reply-To: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 04, 2008 at 03:01:01PM -0800, Glenn Griffin wrote:
> Add IPv6 support to TCP SYN cookies.  This is written and tested against
> 2.6.24, and applies cleanly to linus' current HEAD (d2fc0b).  Unfortunately
> linus' HEAD breaks my sky2 card at the moment, so I'm unable to test against
> that.  I see no reason why it would be affected though.  Comments/suggestions
> are welcome.

Syncookies are discouraged these days. They disable too many 
valuable TCP features (window scaling, SACK) and even without them 
the kernel is usually strong enough to defend against syn floods
and systems have much more memory than they used to be.

So I don't think it makes much sense to add more code to it, sorry.

Besides you should really move it to the ipv6 module, right now the code
would be always compiled in even for ipv4 only kernels.

-Andi
