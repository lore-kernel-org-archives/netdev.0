From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix for b44 warnings.
Date: Mon, 13 Sep 2004 16:33:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913163333.2fadaf93.davem@davemloft.net>
References: <200408292218.00756.jolt@tuxbox.org>
	<20040913163001.7fa560c6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jolt@tuxbox.org, pp@ee.oulu.fi, jgarzik@pobox.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040913163001.7fa560c6@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 16:30:01 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> B44 driver was using unsigned long as an io memory address.
> Recent changes caused this to be a warning.  This patch fixes that
> and makes the readl/writel wrapper into inline's instead of macros
> with magic variable side effect (yuck).

Jeff, I'll merge this one.

Thanks Stephen.
