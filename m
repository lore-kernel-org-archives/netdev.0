From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept()
 andsecurity_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 06:04:04 -0700 (PDT)
Message-ID: <20090421.060404.146628527.davem@davemloft.net>
References: <200904212126.AJD95821.HFMOFtQJOVFLOS@I-love.SAKURA.ne.jp>
	<20090421.053701.234331700.davem@davemloft.net>
	<200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904212152.FHH51019.MHOFVtOFSJFQOL@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 21 Apr 2009 21:52:57 +0900

> David Miller wrote:
>> Put this stuff in userspace, where you say it already is.  The kernel
>> isn't the place to dump every cool feature you want to bring in from
>> userspace.
> If I can do this stuff in userspace, I already put this stuff in userspace.
> Access control in userspace is easily bypassed, no good for policy based
> mandatory access control. The reason I propose these hooks in kernel is that
> nobody can bypass these hooks.

They you have to make your decisions when the packet arrives
in order to not break application expected semantics.

If poll() says to a listening socket that connections are
available, we MUST return a connection from accept() unless
there is a hard error.

The current proposal is not acceptable.
