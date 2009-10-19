From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Mon, 19 Oct 2009 22:11:22 +0200
Message-ID: <20091019201122.GC21437@1wt.eu>
References: <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli> <4AD84D8B.5020103@gmail.com> <Pine.LNX.4.58.0910171417260.7818@u.domain.uli> <4AD9B37A.3090606@gmail.com> <Pine.LNX.4.58.0910171709190.10440@u.domain.uli> <4ADCC58B.2060408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50396 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486AbZJSUL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 16:11:28 -0400
Content-Disposition: inline
In-Reply-To: <4ADCC58B.2060408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 10:01:15PM +0200, Eric Dumazet wrote:
> David, I think we should revert 6d01a026b7d3009a418326bdcf313503a314f1ea
> (tcp: fix tcp_defer_accept to consider the timeout) 
> since we know its broken.

yes I agree with Eric, please revert it and wait for Julian's
patch which gets it right. Sorry for the wrong fix, at least
it will have brought the discussion on the table, but without
a faulty patch it would have been better :-/

Thanks,
Willy

