From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 3/9] use mmiowb in tg3_poll
Date: Thu, 28 Oct 2004 16:43:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164338.4172f235.davem@davemloft.net>
References: <200410280721.i9S7Le907988@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Le907988@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:41 -0700
akpm@osdl.org wrote:

> From: <akepner@sgi.com>
> 
> Returning from tg3_poll() without flushing the PIO write which reenables
> interrupts can result in lower cpu utilization and higher throughput.  So
> use a memory barrier, mmiowb(), instead of flushing the write with a PIO
> read.
> 
> Signed-off-by: Arthur Kepner <akepner@sgi.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Also applied, thanks.
