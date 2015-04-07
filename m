From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage
 socket
Date: Tue, 07 Apr 2015 01:29:39 -0400 (EDT)
Message-ID: <20150407.012939.305450025729368407.davem@davemloft.net>
References: <CALx6S35bZ6t9d+cpHRXYS94N6rGuHhACMAt9Bj6UzCwBuomBSA@mail.gmail.com>
	<20150406.235118.65925113152002205.davem@davemloft.net>
	<CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org, jiri@resnulli.us
To: tom@herbertland.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CALx6S36f8SQQoNvzPyCNk4=0LbH4Od6ZtdDn0DCA2sZGZHMx2g@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 6 Apr 2015 21:45:45 -0700

> I guess this is where I'm confused. We can send just about anything
> over GRE also, but have never needed a transmit socket for that. Is
> UDP encapsulation so different, or is GRE equally broken also? Also,
> will we need to add the socket to FOU and GUE then?

The situation is that if we have a socket we should use it.  More
information and context is better than less.

And making the stack more aware of what context exists happens to fix
a crash too.

Pablo has told me also that extending the output path signature in
this way helps work he is doing too.
