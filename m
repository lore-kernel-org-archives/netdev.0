From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Thu, 11 Oct 2007 21:54:29 -0700 (PDT)
Message-ID: <20071011.215429.108742994.davem@davemloft.net>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
	<18190.61294.191189.193153@cargo.ozlabs.ibm.com>
	<20071011212539.8acafc63.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org, sam@ravnborg.org,
	benh@kernel.crashing.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750930AbXJLEya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 00:54:30 -0400
In-Reply-To: <20071011212539.8acafc63.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 11 Oct 2007 21:25:39 -0700

> On Fri, 12 Oct 2007 13:52:14 +1000 Paul Mackerras <paulus@samba.org> wrote:
> 
> > So Andrew, what do you think is better - arch/powerpc/boot having its
> > own copies of the zlib_inflate stuff, or #ifdefs of some kind in
> > lib/zlib_inflate/*.c?
> 
> 
> The latter - copying code is evil.  Keeping the existing code dual-mode
> shouldn't be too hard - it's just a matter of people knowing about it.
> 
> Perhaps such code should be in its own suitably-named directory, but
> whatever.

I'll work on a fix for this.
