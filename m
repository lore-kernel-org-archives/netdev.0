From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 15:08:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007150850.7ba2a387.davem@davemloft.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
In-Reply-To: <20041007224422.1c1bea95@jack.colino.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004 22:44:22 +0200
Colin Leroy <colin@colino.net> wrote:

> On 07 Oct 2004 at 11h10, David S. Miller wrote:
> 
> Hi again, 
> 
> > So, netpoll needs to have the NETIF_F_LLTX stuff added to it.
> 
> This patch should do that. It works OK for me, but I'd like it checked
> before sent upstream...
> 
> However, it doesn't fix the hang. it looks like this hang is really
> coming from sungem.

Is it hanging inside of the ->hard_start_xmit() call or somewhere
else?  Do you have a way to determine this without adding printk()'s
and thus causing recursion as you mentioned earlier? :-)
