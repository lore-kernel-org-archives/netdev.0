From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] syncppp needs to pullup headers
Date: Fri, 3 Oct 2003 22:55:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003225552.3c8f28d9.davem@redhat.com>
References: <20031003114347.31ee740b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031003114347.31ee740b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 11:43:47 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> In 2.6.0-test6 wan syncppp driver claims to be a "new" protocol and handle shared skb's
> but it needs to make sure data is contiguous before overlaying headers.  
> It is not a serious problem because the sync drivers never generate nonlinear skbuff's
> anyway.

This looks obvious enough and correct to me, applied.
