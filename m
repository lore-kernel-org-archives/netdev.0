From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Mon, 6 Sep 2004 18:23:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040906182328.08faf843.davem@davemloft.net>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<757AB580-0030-11D9-9224-000A95AD0668@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vda@port.imtp.ilyichevsk.odessa.ua, jgarzik@pobox.com, netdev@oss.sgi.com,
        acx100-devel@lists.sourceforge.net, jt@bougret.hpl.hp.com,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <757AB580-0030-11D9-9224-000A95AD0668@errno.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Sep 2004 11:13:31 -0700
Sam Leffler <sam@errno.com> wrote:

> I've suggested this code as a good starting point for a "generic 802.11 
> stack" but received only misinformed responses.

Sam, I've told you multiple times why your stack isn't a good
starting point.  It isn't implemented as a true network stack,
like IPV4, Appletalk, etc.  Instead it's a gross input packet
hooked packet eater thing that's an ugly wart bolted onto the
side of the driver API.
