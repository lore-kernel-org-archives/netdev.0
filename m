From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Netem] [PATCH] (1/3) netem - reinsert for duplication
Date: Thu, 19 May 2005 16:32:35 -0700
Message-ID: <20050519163235.2f5db193@dxpl.pdx.osdl.net>
References: <20050519151250.17ab5c81@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050519151250.17ab5c81@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2005 15:12:50 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Handle duplication of packets in netem by re-inserting at top of qdisc tree.
> This avoid problems with qlen accounting with nested qdisc. This recursion
> requires no additional locking but will potentially increase stack depth.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 

Hold off on applying these patches until next week, I am seeing some timing
anomalies when using this for TCP testing, and not sure if these patches are related.
