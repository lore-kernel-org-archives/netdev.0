From: <raghunathan.venkatesan@wipro.com>
Subject: RE: Unable to handle kernel paging request at virtual address 04000460
Date: Fri, 3 Jun 2005 08:28:34 +0530
Message-ID: <438662DA48DCAA41B1DF648BD4BD76C0E98682@CHN-SNR-MBX01.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>, <linux@der-keiler.de>
Return-path: <linux-net-owner@vger.kernel.org>
Content-class: urn:content-classes:message
To: <shemminger@osdl.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,
I appreciate you response. 
We'll get deeper into the problem after turning on these debugs.

Thanks,
Raghu


-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Thursday, June 02, 2005 11:14 PM
To: Raghunathan Venkatesan (WT01 - EMBEDDED & PRODUCT ENGINEERING
SOLUTIONS)
Cc: davem@davemloft.net; linux-net@vger.kernel.org; netdev@oss.sgi.com;
linux@der-keiler.de
Subject: Re: Unable to handle kernel paging request at virtual address
04000460

On Thu, 2 Jun 2005 09:20:21 +0530
<raghunathan.venkatesan@wipro.com> wrote:

> Hi David,
> I understand that the linux community may not be able to debug it for 
> me. All I require is if people have seen similar problems (the 
> problems we face are w.r.t to kfree_skb and skb_drop_fraglist crashing

> due to some reason, which could be a Memory Management issue or some 
> thing we are not aware of), then let us know the patches, so that we 
> can try them out here.

Turn on Debug memory allocations, spinlock debugging,
sleep-inside-spinlock checking, and preempt, it will help your
debugging.  If you are not building your own kernel from source learn
how.

You are probably freeing memory twice, or not doing ref counting
properly or other locking issues.  Since it is your code, good luck
debugging it, if you want the community help it needs to be open source
code that is available for download or be in the kernel.org kernel.
