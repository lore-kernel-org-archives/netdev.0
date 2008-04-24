From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 20:49:32 +0400
Message-ID: <20080424164932.GB22233@2ka.mipt.ru>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com> <20080424112514.055d8071@the-village.bc.nu> <481096C3.2020206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51381 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbYDXQvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 12:51:42 -0400
Content-Disposition: inline
In-Reply-To: <481096C3.2020206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 07:18:43AM -0700, Ulrich Drepper (drepper@redhat.com) wrote:
> I don't think this is a viable approach because it is not about the
> range.  People can and do select arbitrary values for those types.
> Until a value is officially recognized and registered it is in fact best
> to choose a (possibly large) random value to not conflict with anything
> else.  Who can guarantee that whatever bit is chosen for SOCK_CLOEXEC
> isn't already used by someone?

type argument is limited to SOCK_MAX, higher half of the word can be
used for flags. It is much cleaner than implementing socket4() for the
single bit.

> Add to this that it's not a complete solution (no such hack possible for
> accept) and I think using a new interface is cleaner(tm).

It can inherit flags from parent by default.

-- 
	Evgeniy Polyakov
