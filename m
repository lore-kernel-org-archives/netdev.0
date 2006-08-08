From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] llc: SOCK_DGRAM interface fixes
Date: Tue, 8 Aug 2006 14:54:21 -0300
Message-ID: <20060808175421.GD27312@mandriva.com>
References: <20060803092117.5726b4d7@localhost.localdomain> <20060808163618.GA1992@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [200.250.241.52] ([200.250.241.52]:45070 "EHLO
	oops.ghostprotocols.net") by vger.kernel.org with ESMTP
	id S1030214AbWHHRzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 13:55:06 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060808163618.GA1992@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Aug 08, 2006 at 08:36:18PM +0400, Alexey Kuznetsov escreveu:
> Hello!
> 
> > This fix goes against the old historical comments about UNIX98 semantics
> > but without this fix SOCK_DGRAM is broken and useless. So either ANK's
> > interpretation was incorect or UNIX98 standard was wrong.
> 
> Just found this reference to me. :-)
> 
> The comment migrated from tcp.c. It is only about connected SOCK_STREAM
> sockets, I do not see how it can make SOCK_DGRAM broken or useless.

Its just that the work to get the AF_LLC code closer to the AF_INET
structure was suspended before the SOCK_STREAM code was separated from the
SOCK_DGRAM one, moving PF_LLC to sk->sk_prot-> land, so the comment is
indeed about SOCK_STREAM part, not DGRAM.

- Arnaldo
