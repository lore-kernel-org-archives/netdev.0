From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.35.7] net: Fix the condition passed to sk_wait_event()
Date: Sat, 2 Oct 2010 04:49:20 -0700 (PDT)
Message-ID: <786890.87789.qm@web53703.mail.re2.yahoo.com>
References: <1286008441.2582.851.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286008441.2582.851.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- On Sat, 2/10/10, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Just wondering why you remove the test on sk->err
> ?
> > 
> > We want to break the loop If sk->sk_err is set, or
> state is ESTABLISHED
> > or CLOSE_WAIT.
> 
> Hmm, reading the code again, I can see sk_err is tested in
> the loop, so
> your code is better (sk_stream_wait_connect() returns an
> error after
> your patch, instead of returning 0)

Exactly.

> 
> Could you please split your patch in two patches ?
> 

ok, I'll send it soon.

Thanks,
Tomar




      
