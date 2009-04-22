From: Greg Lindahl <greg@blekko.com>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
	security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 23:10:06 -0700
Message-ID: <20090422061006.GB27688@bx9.net>
References: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp> <20090421.181411.26595688.davem@davemloft.net> <20090422015228.GA13312@bx9.net> <20090421.212342.235921625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:27086 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbZDVGKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 02:10:08 -0400
Content-Disposition: inline
In-Reply-To: <20090421.212342.235921625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 09:23:42PM -0700, David Miller wrote:

> I said explicitly that hard errors are allows (out of file
> descriptors, memory allocation failure)

I have no idea what you meant by a "hard" error. Note that I also
discussed EAGAIN, which appears to happen commonly historically and
today, and appears to be what the security module folks would want to
have happen and you're rejecting. Do you consider that to be a hard
error? I'm betting not.

-- greg


