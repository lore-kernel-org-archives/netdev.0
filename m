From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: NAPI for eepro100
Date: Thu, 13 Jun 2002 12:57:53 +0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae9md0$mm1$2@main.gmane.org>
References: <3D0740ED.2060907@ict.ac.cn> <3D07D270.5060902@mandrakesoft.com> <20020612.160532.134201977.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fxzhang@ict.ac.cn, linux-mips@oss.sgi.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, jgarzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020612.160532.134201977.davem@redhat.com>; from "David S. Miller" on Wed, Jun 12, 2002 at 04:05:32PM
List-Id: netdev.vger.kernel.org

On Wed, Jun 12, 2002 at 04:05:32PM -0700, David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@mandrakesoft.com>
>    Date: Wed, 12 Jun 2002 19:00:00 -0400
>    
>    for the 'mips' patch, it looks 
>    like the arch maintainer(s) need to fix the PCI DMA support...
> 
> No, it's worse than that.
> 
> See how non-consistent memory is used by the eepro100 driver
> for descriptor bits?  The skb->tail bits?
> 
> That is very problematic.

What's the problem?
If it isn't allowed to do, then what is the meaning of PCI_DMA_BIDIRECTIONAL
mappings?

	Andrey
