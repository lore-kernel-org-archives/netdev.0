From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9] address family not supported for sendmsg()
Date: Fri, 22 Oct 2004 22:29:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022222903.0871a216.davem@davemloft.net>
References: <20041022.153137.99739029.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0410222004070.18616-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Suresh Krishnan <suresh.krishnan@ericsson.ca>
In-Reply-To: <Pine.LNX.4.44.0410222004070.18616-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 20:07:01 -0400 (EDT)
Suresh Krishnan <suresh.krishnan@ericsson.ca> wrote:

> Hi Dave/Yoshifuji,
>   I agree that the case you pointed out is tricky. I am fine with either 
> EAFNOSUPPORT or EINVAL. But the POSIX and SUSv3 man pages specify EINVAL 
> as a error only when the sum of iov_len values overflows ssize_t.

I now think EAFNOSUPPORT is fine.

Please resend your patch to me under private cover so I
can apply it Suresh, thanks.
