From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4]: multipath_wrandom.c GPF fixes
Date: Thu, 5 May 2005 14:28:00 -0700
Message-ID: <20050505142800.0b66405a.davem@davemloft.net>
References: <427A828A.3080309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427A828A.3080309@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 May 2005 22:31:06 +0200
Patrick McHardy <kaber@trash.net> wrote:

> multipath_wrandom needs to use GFP_ATOMIC.

I didn't fix this, because none of these allocations even
check the return value so it's kind of pointless.

There is zero error handling in the multipath modules.

But I suppose it's best to get some of this fixed rather
than none of it, so patch applied, thanks.
