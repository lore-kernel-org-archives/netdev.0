From: Chris Leech <christopher.leech@intel.com>
Subject: Re: skb_padto and small fragmented transmits
Date: 06 Feb 2003 11:22:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1044559328.4618.54.camel@localhost.localdomain>
References: <BD9B60A108C4D511AAA10002A50708F20BA2AAE3@orsmsx118.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <BD9B60A108C4D511AAA10002A50708F20BA2AAE3@orsmsx118.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-02-06 at 10:44, David S. Miller wrote:
>    From: Chris Leech <christopher.leech@intel.com>
>    Date: 06 Feb 2003 11:22:51 -0800
>    
>    I fail to see how the statement "skb->len + skb->data_len" has any
>    usable meaning, or how it can be anything other than a bug.
> 
> This equation is the standard way to find the full length
> on any skb.  For linear skbs, data_len is always zero.
> 
> I asked Alan to use this formula so that greps on the source
> tree would always show data_len being taken into account, and
> thus usage would be consistent.

OK, now I'm really getting confused.  Every other example I can find in
the networking code, and every scatter-gather capable driver, uses
skb->len as the full length and skb->len - skb->data_len as the length
of the first or linear portion.
