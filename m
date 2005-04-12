From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Tue, 12 Apr 2005 15:47:28 -0700
Message-ID: <20050412154728.463e3d10.davem@davemloft.net>
References: <425C493B.5040206@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <425C493B.5040206@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Apr 2005 23:18:35 +0100
Baruch Even <baruch@ev-en.org> wrote:

> I was wondering if someone can think of a reason why this happens?

Probably some bug we fixed in 2.6.8 or later...

> Is there a way to get the different network related patches between 
> these two versions? I don't have access to bk to get it myself.

Get patch-2.6.7.bz2 or whatever from kernel.org, then scan around for
changes to include/*/tcp.h and net/ipv4/tcp*.c
