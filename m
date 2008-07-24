From: David Miller <davem@davemloft.net>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 01:36:49 -0700 (PDT)
Message-ID: <20080724.013649.22662901.davem@davemloft.net>
References: <20080724063242.GA9051@elte.hu>
	<E1KLvds-0001Mc-00@gondolin.me.apana.org.au>
	<20080724082730.GA29046@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbYGXIgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 04:36:49 -0400
In-Reply-To: <20080724082730.GA29046@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 24 Jul 2008 10:27:30 +0200

> * Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > BTW any reason why you appear to have SACK off?
> 
> default distro setup, Fedora 9 and Fedora 8. No extra tweaking that i'm 
> aware of.

It's probably a side effect of their turning on syncookies in /etc/sysctl.conf :-/

I thought we added code that would allow enabling those options
even with syncookies enabled?  There is code in net/ipv4/syncookies.c
function cookie_check_timestamp() to handle this.

Of course this is a recent addition, so if either side doesn't
have that change.
