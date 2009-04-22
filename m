From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 21:23:42 -0700 (PDT)
Message-ID: <20090421.212342.235921625.davem@davemloft.net>
References: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp>
	<20090421.181411.26595688.davem@davemloft.net>
	<20090422015228.GA13312@bx9.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@i-love.sakura.ne.jp, paul.moore@hp.com,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: greg@blekko.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090422015228.GA13312@bx9.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Lindahl <greg@blekko.com>
Date: Tue, 21 Apr 2009 18:52:28 -0700

> On Tue, Apr 21, 2009 at 06:14:11PM -0700, David Miller wrote:
> 
>> We had a similar situation with read()'s on UDP sockets.
>> 
>> When poll() says something, it has to stick.
> 
> Isn't that completely different? Anyone who writes code that calls
> accept() quickly finds out that in the real world it fails for all
> kinds of reasons worth ignoring. As an example, a comment in ircd at
> the only accept call (circa 1998):

I said explicitly that hard errors are allows (out of file
descriptors, memory allocation failure)

Feel free to ignore what I'm saying, and I'll feel free to
ignore you too.
