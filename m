From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Thu, 21 Oct 2004 15:44:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021154451.50b07f53.davem@davemloft.net>
References: <20041021133752.67a386fb@zqx3.pdx.osdl.net>
	<20041021142335.54f088ad.davem@davemloft.net>
	<20041021151015.10738f8a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041021151015.10738f8a@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 15:10:15 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> > If the bug reporter had provided an strace of the Amanda userland
> > components, we'd know this already.
> 
> Reading the current source code: 
> 	http://prdownloads.sourceforge.net/amanda/amanda-2.4.4p3.tar.gz?download
> 
> It does sendto() then close() in the udp_send path.
> Also, it suffers from the select() and blocking rcvfrom() problem.

Not to accuse the reporter or anything, but this may be a straw-man
rigged up bug report to try and force our hands in changing the behavior
of this case.

If so, that's quite rude, because kernels have behaved that way
forever, not just in 2.6.9.
