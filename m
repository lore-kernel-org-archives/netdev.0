From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix socket bitop damage
Date: Tue, 23 Aug 2005 09:22:34 -0700 (PDT)
Message-ID: <20050823.092234.112408202.davem__22928.1128304594$1124814524$gmane$org@davemloft.net>
References: <20050822110218.GA7514@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@linux-mips.org, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
In-Reply-To: <20050822110218.GA7514@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 22 Aug 2005 12:02:18 +0100

> The socket flag cleanups that went into 2.6.12-rc1 are basically oring
> the flags of an old socket into the socket just being created.
> Unfortunately that one was just initialized by sock_init_data(), so already
> has SOCK_ZAPPED set.  As the result zapped sockets are created and all
> incoming connection will fail due to this bug which again was carefully
> replicated to at least AX.25, NET/ROM or ROSE.
> 
> In order to keep the abstraction alive I've introduced sock_copy_flags()
> to copy the socket flags from one sockets to another and used that
> instead of the bitwise copy thing.  Anyway, the idea here has probably
> been to copy all flags, so sock_copy_flags() should be the right thing.
> With this the ham radio protocols are usable again, so I hope this will
> make it into 2.6.13.
> 
> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

Applied, thanks Ralf.
