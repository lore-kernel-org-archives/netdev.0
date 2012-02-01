From: David Miller <davem@davemloft.net>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 01 Feb 2012 02:43:57 -0500 (EST)
Message-ID: <20120201.024357.1370213516985704222.davem@davemloft.net>
References: <CAGsizzLTHw5Ja3kT-zEN8uK5GrzpmN1bxOhA0OscGL5R6tH3WA@mail.gmail.com>
	<20120131.190830.1189531706541596294.davem@davemloft.net>
	<CAGsizzKB=NcAe9KvfZbbPiGvSQ6a9Mj+kBaKtDQziGWJ+eGGRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522Ab2BAHqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 02:46:37 -0500
In-Reply-To: <CAGsizzKB=NcAe9KvfZbbPiGvSQ6a9Mj+kBaKtDQziGWJ+eGGRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Wed, 1 Feb 2012 08:22:02 +0100

> So if this is now only about the
> maintenance of my code, I'll be more than happy to continue
> maintaining it myself together with you guys.

You have a very warped understanding of what maintainence cost means.

Everyone time someone wants to change a core API in the networking
your new code will need to be considered.  Every time someone wants to
audit how an interface is used, your code adds to the audit burdon.

And this is burdon placed upon other people, even if you personally
"promise" to maintain this specific code snippet.  This promise
completely meaningless from a global kernel maintainence standpoint.

More code has a cost, no matter how well that specific piece of code
is maintained.

Therefore we don't add supurious code, and your code is spurious if it
will end up duplicating a more desirable implementation and interface
for this functionality.

The world has spun successfully countless times in the 18 years that
Linux hasn't had support for the feature you are so gravely interested
in including "right now", and I suspect it will spin successfully a
few more times while a proper implementation is ironed out.
