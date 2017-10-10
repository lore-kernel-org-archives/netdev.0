From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] once: switch to new jump label API
Date: Mon, 09 Oct 2017 20:26:37 -0700 (PDT)
Message-ID: <20171009.202637.490575732444034495.davem@davemloft.net>
References: <20171009213052.97771-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        hannes@stressinduktion.org, jbaron@akamai.com,
        peterz@infradead.org, ebiggers@google.com
To: ebiggers3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009213052.97771-1-ebiggers3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers <ebiggers3@gmail.com>
Date: Mon,  9 Oct 2017 14:30:52 -0700

> From: Eric Biggers <ebiggers@google.com>
> 
> Switch the DO_ONCE() macro from the deprecated jump label API to the new
> one.  The new one is more readable, and for DO_ONCE() it also makes the
> generated code more icache-friendly: now the one-time initialization
> code is placed out-of-line at the jump target, rather than at the inline
> fallthrough case.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thank you.
