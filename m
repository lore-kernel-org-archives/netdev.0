From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4]: multipath_wrandom.c GPF fixes
Date: Fri, 06 May 2005 00:33:15 +0200
Message-ID: <427A9F2B.2060804@trash.net>
References: <427A828A.3080309@trash.net> <20050505142800.0b66405a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050505142800.0b66405a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> I didn't fix this, because none of these allocations even
> check the return value so it's kind of pointless.
> 
> There is zero error handling in the multipath modules.
> 
> But I suppose it's best to get some of this fixed rather
> than none of it, so patch applied, thanks.

The first one is already checked, I'll look into the others.

Regards
Patrick
