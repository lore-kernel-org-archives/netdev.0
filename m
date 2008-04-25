From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] socket, socketpair w/flags, accept4
Date: Fri, 25 Apr 2008 08:29:57 +0400
Message-ID: <20080425042957.GA17699@2ka.mipt.ru>
References: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44550 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbYDYEan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 00:30:43 -0400
Content-Disposition: inline
In-Reply-To: <200804241820.m3OIKlMK017580@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Apr 24, 2008 at 02:20:47PM -0400, Ulrich Drepper (drepper@redhat.com) wrote:
> The code changes are really minimal.  And don't get too hung up on the
> internal name of the syscall.  I think accept4 is more desriptive than
> paccept since a) suffixes more easily indicate derived functionality
> and b) the 4 actually indicates to the initiated what has changed.
> If there are good reasons otherwise the userlevel interface can still
> be something completely different.

What about sigset there too?

-- 
	Evgeniy Polyakov
