From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() andsecurity_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 21:52:57 +0900
Message-ID: <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp>
References: <200904212039.JID59468.LOFOtMQOFJFSVH@I-love.SAKURA.ne.jp>
	<20090421.044053.155783771.davem@davemloft.net>
	<200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp>
	<20090421.053701.234331700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.053701.234331700.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Put this stuff in userspace, where you say it already is.  The kernel
> isn't the place to dump every cool feature you want to bring in from
> userspace.
If I can do this stuff in userspace, I already put this stuff in userspace.
Access control in userspace is easily bypassed, no good for policy based
mandatory access control. The reason I propose these hooks in kernel is that
nobody can bypass these hooks.
