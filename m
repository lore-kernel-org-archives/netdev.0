From: "David S. Miller" <davem@redhat.com>
Subject: Re: skb_padto and small fragmented transmits
Date: Thu, 06 Feb 2003 14:43:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030206.144306.14966745.davem@redhat.com>
References: <BD9B60A108C4D511AAA10002A50708F20BA2AAE3@orsmsx118.jf.intel.com>
	<1044559328.4618.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: christopher.leech@intel.com
In-Reply-To: <1044559328.4618.54.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Leech <christopher.leech@intel.com>
   Date: 06 Feb 2003 11:22:08 -0800
   
   OK, now I'm really getting confused.  Every other example I can find in
   the networking code, and every scatter-gather capable driver, uses
   skb->len as the full length and skb->len - skb->data_len as the length
   of the first or linear portion.
   
Indeed, Alan you need to fix the skb_padto stuff to use
skb->len, ignore the skb->data_len as skb->len is the
full length.

Sorry for telling you to do the wrong thing Alan, my bad :)
