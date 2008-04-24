From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 15:24:36 +0100
Message-ID: <20080424152436.6cf53c1b@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
	<20080424112514.055d8071@the-village.bc.nu>
	<481096C3.2020206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758760AbYDXOxy@vger.kernel.org>
In-Reply-To: <481096C3.2020206@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I don't think this is a viable approach because it is not about the
> range.  People can and do select arbitrary values for those types.
> Until a value is officially recognized and registered it is in fact best
> to choose a (possibly large) random value to not conflict with anything
> else.  Who can guarantee that whatever bit is chosen for SOCK_CLOEXEC
> isn't already used by someone?

There are only a small number of valid socket types recognized by POSIX
plus a few BSD plus a few Linux ones so Linux can happily assign the
upper bits for a different purpose.

> Add to this that it's not a complete solution (no such hack possible for
> accept) and I think using a new interface is cleaner(tm).

Every other property of a socket via accept() is inherited from the
parent. Making one property different would be bizarre and ugly.

Alan
