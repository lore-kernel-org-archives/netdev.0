From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.24 breaks powerpc mysteriously
Date: Thu, 11 Oct 2007 21:25:39 -0700
Message-ID: <20071011212539.8acafc63.akpm@linux-foundation.org>
References: <20071011192233.23e1c6bc.akpm@linux-foundation.org>
	<18190.61294.191189.193153@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52576 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754559AbXJLEZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 00:25:46 -0400
In-Reply-To: <18190.61294.191189.193153@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 13:52:14 +1000 Paul Mackerras <paulus@samba.org> wrote:

> So Andrew, what do you think is better - arch/powerpc/boot having its
> own copies of the zlib_inflate stuff, or #ifdefs of some kind in
> lib/zlib_inflate/*.c?


The latter - copying code is evil.  Keeping the existing code dual-mode
shouldn't be too hard - it's just a matter of people knowing about it.

Perhaps such code should be in its own suitably-named directory, but
whatever.
