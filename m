From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.11 on AMD64 traps
Date: Thu, 10 Mar 2005 18:20:44 -0800
Message-ID: <20050310182044.1d740738.davem@davemloft.net>
References: <200503081900.18686.vanco@satro.sk>
	<422DF07D.7010908@tomt.net>
	<422F525F.90404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andre@tomt.net, vanco@satro.sk, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422F525F.90404@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Mar 2005 20:45:35 +0100
Patrick McHardy <kaber@trash.net> wrote:

> > Michal Vanco wrote:
> >>
> >> I see this problem running 2.6.11 on dual AMD64:
> >>
> >> Running quagga routing daemon (ospf+bgp) and issuing "netstat -rn |wc 
> >> -l" command
> >> while quagga tries to load more than 154000 routes from its bgp 
> >> neighbours causes this trap:
> 
> This patch should fix it. The crash is caused by stale pointers,
> the pointers in fib_iter_state are not reloaded after seq->stop()
> followed by seq->start(pos > 0).

Applied, thanks Patrick.
