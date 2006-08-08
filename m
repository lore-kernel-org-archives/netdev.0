From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] llc: SOCK_DGRAM interface fixes
Date: Tue, 8 Aug 2006 20:36:18 +0400
Message-ID: <20060808163618.GA1992@ms2.inr.ac.ru>
References: <20060803092117.5726b4d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:1195 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964981AbWHHQhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 12:37:17 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060803092117.5726b4d7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This fix goes against the old historical comments about UNIX98 semantics
> but without this fix SOCK_DGRAM is broken and useless. So either ANK's
> interpretation was incorect or UNIX98 standard was wrong.

Just found this reference to me. :-)

The comment migrated from tcp.c. It is only about connected SOCK_STREAM
sockets, I do not see how it can make SOCK_DGRAM broken or useless.

That UNIX98 statement allowed to avoid expensive callback to protocol
specific setup of address in tcp_recvmsg().

Alexey
