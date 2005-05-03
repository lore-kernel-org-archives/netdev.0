From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ppp: remove redundant NULL pointer checks before kfree
 & vfree
Date: Tue, 3 May 2005 14:37:26 -0700
Message-ID: <20050503143726.63758ce3.davem@davemloft.net>
References: <Pine.LNX.4.62.0504290049240.2476@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.62.0504290049240.2476@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2005 00:54:44 +0200 (CEST)
Jesper Juhl <juhl-lkml@dif.dk> wrote:

> kfree() and vfree() can both deal with NULL pointers. This patch removes 
> redundant NULL pointer checks from the ppp code in drivers/net/
> 
> Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

Applied, thanks Jesper.
