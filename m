From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: skb_padto and small fragmented transmits
Date: 07 Feb 2003 13:33:41 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1044624820.14026.7.camel@irongate.swansea.linux.org.uk>
References: <BD9B60A108C4D511AAA10002A50708F20BA2AAE3@orsmsx118.jf.intel.com>
	 <1044559328.4618.54.camel@localhost.localdomain>
	 <20030206.144306.14966745.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, netdev@oss.sgi.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030206.144306.14966745.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-02-06 at 22:43, David S. Miller wrote:
>    From: Chris Leech <christopher.leech@intel.com>
>    Date: 06 Feb 2003 11:22:08 -0800
>    
>    OK, now I'm really getting confused.  Every other example I can find in
>    the networking code, and every scatter-gather capable driver, uses
>    skb->len as the full length and skb->len - skb->data_len as the length
>    of the first or linear portion.
>    
> Indeed, Alan you need to fix the skb_padto stuff to use
> skb->len, ignore the skb->data_len as skb->len is the
> full length.

Dave just fix it next time you touch the code and push it to Marcelo. It
doesnt affect the 2.2 backport so that will be ok
