From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RESEND] [PATCH 2.6.11.7] sch_htb: Drop packet when direct
 queue is full
Date: Tue, 3 May 2005 14:39:30 -0700
Message-ID: <20050503143930.28650cba.davem@davemloft.net>
References: <Pine.LNX.4.61.0504291725000.28792@limnos.csrd.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <Pine.LNX.4.61.0504291725000.28792@limnos.csrd.uiuc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Apr 2005 17:33:12 +0000 (UTC)
Asim Shankar <asimshankar@gmail.com> wrote:

> htb_enqueue(): Free skb and return NET_XMIT_DROP if a packet is
> destined for the direct_queue but the direct_queue is full. (Before
> this: erroneously returned NET_XMIT_SUCCESS even though the packet was
> not enqueued)
> 
> Signed-off-by: Asim Shankar <asimshankar@gmail.com>

Applied, thanks Asim.
