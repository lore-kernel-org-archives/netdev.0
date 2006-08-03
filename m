From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: Re: [PATCH] llc: SOCK_DGRAM interface fixes
Date: Thu, 03 Aug 2006 13:38:51 -0300
Message-ID: <44D2269B.4030205@mandriva.com>
References: <20060803092117.5726b4d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:48317 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S964846AbWHCQjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 12:39:01 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060803092117.5726b4d7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The datagram interface of LLC is broken in a couple of ways.

I don't doubt it, most of the testing was done on the SOCK_STREAM code,
Jay Schullist worked a bit on the dgram side of things but that was long
ago.

The plan is to use sk->sk_prot-> in the same way as the INET transport
protocols, to clearly separate STREAM from DGRAM code, etc. Its yet
another thing on my longish backlog, sigh.

Dave, please apply.

Acked-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

- Arnaldo
