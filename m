From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [REGRESSION][PATCH V4 3/3] bpf jit: Let the powerpc jit handle
 negative offsets
Date: Tue, 01 May 2012 07:55:26 +1000
Message-ID: <1335822926.20866.47.camel@pasglop>
References: <1335760199.20866.33.camel@pasglop>
	 <4F9E188E.80503@googlemail.com> <1335763568.20866.37.camel@pasglop>
	 <20120430.134140.1738751315208907289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kaffeemonster@googlemail.com, eric.dumazet@gmail.com,
	matt@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120430.134140.1738751315208907289.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-30 at 13:41 -0400, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Mon, 30 Apr 2012 15:26:08 +1000
> 
> > David, what's the right way to fix that ?
> 
> There is no doubt that sock_fprog is the correct datastructure to use.

Ok, so the right fix is to email anybody who posted code using struct
bpf_program to fix their code ? :-)

My question was more along the lines of should we attempt changing one
of the two variants to make them match on BE (since they are in effect
compatible on LE), tho of course this could have the usual annoying
consequence of breaking the mangled c++ name of the symbol).

>From your reply I assume the answer is no... so that leaves us to chase
up users and fix them. Great....

Cheers,
Ben.
