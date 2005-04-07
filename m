From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 13:37:54 -0700
Message-ID: <20050407133754.32d343b2.davem@davemloft.net>
References: <20050407164146.GA6479@ev-en.org>
	<20050407113351.17f8c094.davem@davemloft.net>
	<42558771.1050605@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <42558771.1050605@ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Apr 2005 20:18:09 +0100
Baruch Even <baruch@ev-en.org> wrote:

> This change seems to be specific to us (Hamilton), I didn't find it as 
> far back as 2.4.12 [1], it wasn't in any 2.6.x kernel and not even in 
> web100 version alpha 2.3.2 which corresponds to kernel 2.4.23.
> 
> It does appear in the original patches that Doug Leith sent, so the only 
> explanation left is that it's something he did in his tree originally. 
> And for some reason I believed it was reverting an old change in the 
> Linux kernel.

That makes sense.

And as John Heffner has pointed out, this change is correct and is
part of rate-halving.
