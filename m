From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH/FIX] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Wed, 29 May 2013 10:11:47 +0200
Message-ID: <20130529081147.GC24933@gmail.com>
References: <cover.1369177867.git.luto@amacapital.net>
 <aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
 <20130528085600.GD30172@gmail.com>
 <20130528.235628.1501314742626907861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: luto@amacapital.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, x86@kernel.org,
	trinity@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <trinity-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130528.235628.1501314742626907861.davem@davemloft.net>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue, 28 May 2013 10:56:00 +0200
> 
> > MSG_CMSG_COMPAT is (AFAIK) not intended to be part of the API --
> > it's a hack that steals a bit to indicate to other networking code
> > that a compat entry was used.  So don't allow it from a non-compat
> > syscall.
> > 
> > This prevents an oops when running this code:
>  ...
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> 
> Applied and queued up for -stable.

Thanks David!

	Ingo
