From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 09:43:07 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
References: <20081010.144921.115563930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59472 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753733AbYJKQnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 12:43:41 -0400
In-Reply-To: <20081010.144921.115563930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 10 Oct 2008, David Miller wrote:
>=20
> Here are the queued up networking changes for the 2.6.28 merge window=
=2E

This generates _tons_ of new warnings for me:

  net/netfilter/nf_conntrack_ftp.c: In function =A1update_nl_seq=A2:
  net/netfilter/nf_conntrack_ftp.c:340: warning: passing argument 2 of =
=A1nf_conntrack_event_cache=A2 from incompatible pointer type
  net/netfilter/nf_conntrack_ftp.c:344: warning: passing argument 2 of =
=A1nf_conntrack_event_cache=A2 from incompatible pointer type

Please fix ASAP.

Pulled, but unhappy about warnings in my limited configuration.

		Linus
