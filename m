From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: "eth%d" - net dev name in 2.6?
Date: Wed, 10 Mar 2004 15:59:06 +0100
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <20040310145906.GA9104@linux-mips.org>
References: <20040310023308.GU31326@mvista.com> <20040310025346.GA5661@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jun Sun <jsun@mvista.com>, linux-mips@linux-mips.org,
	netdev@oss.sgi.com
Return-path: <linux-mips-bounce@linux-mips.org>
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20040310025346.GA5661@deprecation.cyrius.com>
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 10, 2004 at 02:53:46AM +0000, Martin Michlmayr wrote:

> I have no idea, but I've seen a similar bug report at
> http://bugs.debian.org/234817

This affects drivers/net/ne.c, so I'm adding netdev to the cc list.

Same problem, dereferencing net_device->name before register_netdev().
That's caused by a bit toooo quick and sloopy conversion from
init_etherdev to alloc_etherdev & register_netdev.

  Ralf
