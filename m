From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] move tc_u32_mark into pkt_cls.h
Date: Thu, 10 Mar 2005 18:42:59 -0800
Message-ID: <20050310184259.51f1e474.davem@davemloft.net>
References: <20050310104207.1d74ac00@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050310104207.1d74ac00@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 10:42:07 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The tc_u32_mark structure is used as part of the netlink message
> from the user API to the kernel, so it needs to be moved to include/linux/pkt_cls.h
> and have types changed from u32 to __u32.
> 
> Also, the definition of u32 performance counters doesn't need to depend
> on the config option.  The definition can exist even if the code isn't
> enabled.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
