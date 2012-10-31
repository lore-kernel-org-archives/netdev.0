From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE to return an interface name
Date: Wed, 31 Oct 2012 13:47:01 -0700
Message-ID: <m2wqy6jrne.fsf@firstfloor.org>
References: <509184D9.8030103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61525 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760393Ab2JaUwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 16:52:45 -0400
In-Reply-To: <509184D9.8030103@hp.com> (Brian Haley's message of "Wed, 31 Oct
	2012 16:06:49 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> writes:

> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
> will then require another call like if_indextoname() to get the actual interface
> name, have it return the name directly.
>
> This also matches the existing man page description on socket(7) which mentions
> the argument being an interface name.
>
> If the value has not been set, zero is returned and optlen will be set to zero
> to indicate there is no interface name present.

That will break all existing programs using the return value, right?
Better to fix the manpage

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
