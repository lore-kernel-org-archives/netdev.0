From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] bridge: no update when hold time is zero
Date: Mon, 14 Mar 2005 21:40:22 -0800
Message-ID: <20050314214022.623ff3b0.davem@davemloft.net>
References: <20050310154437.1223b6e9@dxpl.pdx.osdl.net>
	<20050310185152.12ed9819.davem@davemloft.net>
	<20050311102636.30934f12@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050311102636.30934f12@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005 10:26:36 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Some users, set hold time to zero on bridge so it always does
> flooding. This is usually when using it with wireless.  The new RCU
> based code changed the behaviour so the bridge would not flood for
> one GC interval. This patch restores the original behaviour.

Applied, thanks Stephen.

Please don't forget the signed-off-by line next time :-)
