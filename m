From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tun
Date: Mon, 15 Mar 2004 12:47:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315124751.4808bf45.davem@redhat.com>
References: <20040315102810.2111a5d7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, vtun@office.satix.net.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040315102810.2111a5d7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 10:28:10 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Tun verifies the user address before doing memcpy_from/toiovec.  There are
> two problems with this strategy.  First, it is possible on an SMP machine
> to construct cases where a page is unmmapped between the verify and the copy,
> and it is also faster to do the verification only once.

Yes, those verify_area calls are superfluous and racy.

Applied, thanks Stephen.
