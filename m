From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: restart device after inserting packets
Date: Wed, 8 Dec 2004 21:00:31 -0800
Message-ID: <20041208210031.63f0963f.davem@davemloft.net>
References: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041208123103.4cc6b005@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Dec 2004 12:31:03 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The version of netem in 2.6.10 moves packets from the delayed queue
> to the qdisc in a timer interrupt. But it forgot to force the device to
> pick them up.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Good spotting.  Applied, thanks Stephen.
