From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Fri, 18 May 2012 00:49:07 +0200
Message-ID: <20120517224907.GW14498@1wt.eu>
References: <20120517222431.GT14498@1wt.eu> <20120517.182545.91312407467980757.davem@davemloft.net> <20120517223028.GV14498@1wt.eu> <20120517.183520.1377234710702090939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2363 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030492Ab2EQWtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 18:49:12 -0400
Content-Disposition: inline
In-Reply-To: <20120517.183520.1377234710702090939.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 06:35:20PM -0400, David Miller wrote:
> BTW, this issue goes back all the way to the original implementation
> of do_tcp_sendpages().

I'm not surprized, I remember about tux on 2.4 sometimes leaving frozen
connections behind it when pushed to extreme speeds back in the days where
it was audacious to pull 2 Gbps out of a Pentium3.

I like it when we find very old issues when improving the code, it generally
means we're stressing it a bit more and making more efficient use of it.

Cheers,
Willy
