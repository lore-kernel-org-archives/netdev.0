From: "David S. Miller" <davem@redhat.com>
Subject: Re: skb_padto and small fragmented transmits
Date: Thu, 06 Feb 2003 10:44:24 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030206.104424.39167597.davem@redhat.com>
References: <BD9B60A108C4D511AAA10002A50708F20BA2AAD1@orsmsx118.jf.intel.com>
	<1044559370.4620.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: christopher.leech@intel.com
In-Reply-To: <1044559370.4620.36.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Leech <christopher.leech@intel.com>
   Date: 06 Feb 2003 11:22:51 -0800
   
   I fail to see how the statement "skb->len + skb->data_len" has any
   usable meaning, or how it can be anything other than a bug.

This equation is the standard way to find the full length
on any skb.  For linear skbs, data_len is always zero.

I asked Alan to use this formula so that greps on the source
tree would always show data_len being taken into account, and
thus usage would be consistent.
