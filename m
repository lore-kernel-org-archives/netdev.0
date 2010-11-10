From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 1/2] qlge: Add firmware info to ethtool get
	regs.
Date: Wed, 10 Nov 2010 11:24:30 -0800
Message-ID: <20101110192430.GJ11455@linux-ox1b.qlogic.org>
References: <1288191507-1994-1-git-send-email-ron.mercer@qlogic.com> <20101108.134302.102548897.davem@davemloft.net> <20101108.134932.116391208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ying Ping Lok <ying.lok@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:40559 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753608Ab0KJTgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 14:36:45 -0500
Content-Disposition: inline
In-Reply-To: <20101108.134932.116391208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 01:49:32PM -0800, David Miller wrote:
> 
> Nevermind, reverted, can you please more carefully build test
> your changes?
> 
> drivers/net/qlge/qlge_mpi.c:90:12: error: static declaration of 'ql_soft_reset_mpi_risc' follows non-static declaration
> drivers/net/qlge/qlge.h:2224:5: note: previous declaration of 'ql_soft_reset_mpi_risc' was here
> 
> The line that added the extern declaration to qlge.h seems to be completely
> unrelated to the rest of the patch, as if it's a mis-commit or something
> from another change you were working on.

Dave,  I think another patch (correctly) set this function to static
before ours got applied.  Corrected patch is on it's way.

Thanks
