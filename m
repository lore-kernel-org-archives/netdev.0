From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: NAPI for eepro100
Date: Wed, 12 Jun 2002 19:17:58 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae8l62$6q3$2@main.gmane.org>
References: <3D0740ED.2060907@ict.ac.cn>	<3D07D270.5060902@mandrakesoft.com> <20020612.160532.134201977.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fxzhang@ict.ac.cn, linux-mips@oss.sgi.com, saw@saw.sw.com.sg,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
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


Oh crap, you're right...   eepro100 in general does funky stuff with the 
way packets are handled, mainly due to the need to issue commands to the 
NIC engine instead of the normal per-descriptor owner bit way of doing 
things.

Well, I accept patches to that clean eepro100 up...   I'm not terribly 
motivated to clean it up myself, as we have e100 and an e100 maintainer 
we can beat on if such uglies arise :)

	Jeff
