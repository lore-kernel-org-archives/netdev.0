From: Andi Kleen <andi@firstfloor.org>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 19:26:53 +0200
Message-ID: <20070919172653.GB18045@one.firstfloor.org>
References: <46F13E8B.4050309@redhat.com> <p73sl5aveqh.fsf@bingen.suse.de> <46F15305.2030507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55131 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbXISR0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:26:54 -0400
Content-Disposition: inline
In-Reply-To: <46F15305.2030507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 09:49:09AM -0700, Ulrich Drepper wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andi Kleen wrote:
> > The standard way to undo connect is to use AF_UNSPEC. Code to handle
> > that for dgram sockets is there. It's the same code for v4 and v6.
> 
> I quoted the standard and it does not say anything about AF_UNSPEC.  So
> you cannot simply make such broad statements.

Ok "standard" was perhaps a poor choice of words.

AF_UNSPEC used to be introduced long ago by Alan based on some early 
POSIX draft iirc.

Also incidentially it's a null address:

include/linux/socket.h:#define AF_UNSPEC        0

> But the spec calls for a "null address" to be used and that's in my
> understanding something different from using AF_UNSPEC.

memset(&sockaddr, 0, sizeof(sockaddr)) should give you AF_UNSPEC

-Andi
