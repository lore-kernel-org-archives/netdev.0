From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 3320] New: 2.6 kernel trigger happy to
 load ipv6 module
Date: Tue, 31 Aug 2004 13:54:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831135426.57d47f5a.davem@davemloft.net>
References: <20040831115241.1cc516d3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040831115241.1cc516d3.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


People who don't want features available, should not enable
it (even modular) in their kernels.

Socket calls are going to auto-load protocols by default.

And you can work around this by defining a bogus alias
for that protocol family value in the module tools config
files.

So this bugzilla doesn't have a leg to stand on, I'm afraid.
