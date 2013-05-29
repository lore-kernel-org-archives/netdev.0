From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/FIX] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Tue, 28 May 2013 23:56:28 -0700 (PDT)
Message-ID: <20130528.235628.1501314742626907861.davem@davemloft.net>
References: <cover.1369177867.git.luto@amacapital.net>
	<aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
	<20130528085600.GD30172@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, x86@kernel.org,
	trinity@vger.kernel.org
To: mingo@kernel.org
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20130528085600.GD30172@gmail.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@kernel.org>
Date: Tue, 28 May 2013 10:56:00 +0200

> MSG_CMSG_COMPAT is (AFAIK) not intended to be part of the API --
> it's a hack that steals a bit to indicate to other networking code
> that a compat entry was used.  So don't allow it from a non-compat
> syscall.
> 
> This prevents an oops when running this code:
 ...
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Applied and queued up for -stable.
