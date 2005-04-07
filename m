From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 11:33:51 -0700
Message-ID: <20050407113351.17f8c094.davem@davemloft.net>
References: <20050407164146.GA6479@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <20050407164146.GA6479@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Apr 2005 19:41:46 +0300
Baruch Even <baruch@ev-en.org> wrote:

> However, in tcp_cwnd_down we will not stop reducing the cwnd until we
> get to limit which is set to tp->ssthresh/2.
> 
> The provided patch will set limit to tp->ssthresh. This was the original
> behaviour in some older version of Linux.

As stated in another email, it is still unknown where this "changed"
or if it even "changed" at all in the vanilla sources.

Could you track this down?  I still strongly believe this is some
WEB100 change you actually had in your tree, or something like
that.

I don't disagree with your analysis at all.  I just want to find out
if it did change in the vanilla sources.  Because if it did we can
track down a changelog message and perhaps learn something about what
the code is the way it is.
