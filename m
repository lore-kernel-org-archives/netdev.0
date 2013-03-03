From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: atl1c: DMA: Out of SW-IOMMU space
Date: Sun, 3 Mar 2013 01:48:06 +0000
Message-ID: <157393863283F442885425D2C4542856489D5748@nasanexd02f.na.qualcomm.com>
References: <CAHsu+b8JkVPbh7p7pj4u2XFJ3oA+HfxiGVJyz7TLG3FNQzBZCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Andre Heider <a.heider@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth02.qualcomm.com ([65.197.215.38]:2486 "EHLO
	sabertooth02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3CCBsJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 20:48:09 -0500
In-Reply-To: <CAHsu+b8JkVPbh7p7pj4u2XFJ3oA+HfxiGVJyz7TLG3FNQzBZCQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is another patch follows commit ac574804d412047e52de4dd887615cc88f58aeb0, would you have a try ?

Thanks
Xiong 

> -----Original Message-----
> From: Andre Heider [mailto:a.heider@gmail.com]
> Sent: Sunday, March 03, 2013 1:29 AM
> To: netdev@vger.kernel.org; Huang, Xiong
> Subject: atl1c: DMA: Out of SW-IOMMU space
> 
> The problem doesn't exist on v3.8-rc7.
> 
> The only atl1c commit in v3.8-rc7..v3.8 is:
> 
> commit ac574804d412047e52de4dd887615cc88f58aeb0
> Author: Huang, Xiong <xiong@qca.qualcomm.com>
> Date:   Mon Feb 11 14:44:40 2013 +0000
> 
>     atl1c: add error checking for pci_map_single functions
> 
>     it is reported that code hit DMA-API errors on 3.8-rc6+,
>     (see https://bugzilla.redhat.com/show_bug.cgi?id=908436, and
>          https://bugzilla.redhat.com/show_bug.cgi?id=908550)
> 
>     this patch just adds error handler for
>         pci_map_single and skb_frag_dma_map.
> 
>     Signed-off-by: xiong <xiong@qca.qualcomm.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Reverting that on top of v3.8 seems to fix the problem in my little testing, so
> it sounds like that fix introduced a iommu leak?
> 
> Thanks,
> Andre
