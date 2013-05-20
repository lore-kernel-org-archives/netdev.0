From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Mon, 20 May 2013 07:26:33 -0700
Message-ID: <1369059993.3301.174.camel@edumazet-glaptop>
References: <1368844623.3301.142.camel@edumazet-glaptop>
	 <20130520141941.GA16412@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520141941.GA16412@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 16:19 +0200, Florian Westphal wrote:

> What about emitting additional instructions at random locations in the
> generated code itself?
> 
> Eg., after every instruction, have random chance to insert
> 'xor $0xcc,%al; xor $0xcc,%al', etc?

This will be the latest thing I'll do.

Frankly, whole point of BPF JIT is speed.

If we have slow code, just use the interpretor instead.
