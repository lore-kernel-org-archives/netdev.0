From: "David S. Miller" <davem@redhat.com>
Subject: Re: skb_padto and small fragmented transmits
Date: Sat, 08 Feb 2003 00:53:03 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030208.005303.80023391.davem@redhat.com>
References: <1044559328.4618.54.camel@localhost.localdomain>
	<20030206.144306.14966745.davem@redhat.com>
	<1044624820.14026.7.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1044624820.14026.7.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 07 Feb 2003 13:33:41 +0000

   On Thu, 2003-02-06 at 22:43, David S. Miller wrote:
   > Indeed, Alan you need to fix the skb_padto stuff to use
   > skb->len, ignore the skb->data_len as skb->len is the
   > full length.
   
   Dave just fix it next time you touch the code and push it to Marcelo. It
   doesnt affect the 2.2 backport so that will be ok
   
Ok, I will take care of this.
