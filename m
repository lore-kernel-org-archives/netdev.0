From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] asm/unaligned.h doesn't work well as the very first
	include
Date: Sun, 27 Apr 2008 07:12:10 +0100
Message-ID: <20080427061210.GT5882@ZenIV.linux.org.uk>
References: <20080427051918.GO5882@ZenIV.linux.org.uk> <20080427060944.GB9199@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41878 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbYD0GMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 02:12:12 -0400
Content-Disposition: inline
In-Reply-To: <20080427060944.GB9199@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 08:09:44AM +0200, Sam Ravnborg wrote:

> It has been discussed that any .h file should pull
> in what it needs so the other of includes does not matter.
> Some do them alphabetically.

It has been discussed or it has been agreed?  IMO it's a bullshit - especially
for low-level stuff like that.

As for the way some do includes...  It's not exactly a family-friendly list,
but still I'd rather not comment in details on the existing practices...
