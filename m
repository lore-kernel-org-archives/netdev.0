From: "David S. Miller" <davem@davemloft.net>
Subject: Re: netdev ioctl & dev_base_lock : bad idea ?
Date: Thu, 9 Dec 2004 15:19:08 -0800
Message-ID: <20041209151908.7f84eaf6.davem@davemloft.net>
References: <1101458929.28048.9.camel@gaston>
	<20041208220642.6984519f.davem@davemloft.net>
	<1102573333.16495.2.camel@gaston>
	<20041208231331.40cd98ad.davem@davemloft.net>
	<1102630475.22746.7.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1102630475.22746.7.camel@gaston>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 09:14:35 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> Also, why would we need the xmit lock when calling netif_wake_queue() ?
> I'm not sure I get that one (but I'm not too familiar with the net core
> neither).

Hmmm, you're right, it seems it is not needed.
