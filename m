From: "Nguyen Tuan Huy \(G11\)" <huynt1@fsoft.com.vn>
Subject: RE: [TSO]-Refer to "State of TCP segmentation offload to NIC in  linux"
Date: Mon, 25 May 2009 13:57:48 +0700
Message-ID: <AB6488BF71876F4498928F5DDA52616883103F@ITCGCL02BE.fsoft.fpt.vn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fsoft.com.vn ([210.245.13.222]:58693 "EHLO
	mail.fsoft.com.vn" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbZEYG5t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 02:57:49 -0400
Received: from ITCGCL02BE.fsoft.fpt.vn (itcgsv03be.fsoft.fpt.vn [10.16.34.43])
	by mail.fsoft.com.vn (Postfix) with ESMTP id 80AB32A8D49
	for <netdev@vger.kernel.org>; Mon, 25 May 2009 13:56:13 +0700 (ICT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben.

>I think you won't see 64K packets for a TCP connection that was just
>opened, due to the slow start algorithm.

I have dumped the packets that passed to the hardware. I found that
these packets are always MTU size. 

I think that it must have one flag indicate that when it is turn on,
packet will not framed by TCP/IP layer, but hardware. 
At first I think that is NETIF_F_TSO, but it is not correct.

My kernel version is 2.6.11.12

Best regards,
Huy

-----Original Message-----
From: Ben Hutchings [mailto:ben@decadent.org.uk] 
Sent: Sunday, May 24, 2009 8:16 PM
To: Nguyen Tuan Huy (G11)
Cc: netdev@vger.kernel.org
Subject: Re: [TSO]-Refer to "State of TCP segmentation offload to NIC in
linux"

On Sun, 2009-05-24 at 18:38 +0700, Nguyen Tuan Huy (G11) wrote:
> Dear Mr Ben Hutchings, 
> 
>  
> 
> I have read your answer about question "State of TCP segmentation
> offload to NIC in linux". 
> 
> The link is
> http://kerneltrap.org/mailarchive/linux-netdev/2008/5/7/1757954/thread

Please direct your queries to the netdev list, not to me personally.

> I am now writing network device driver that support TSO function. But
> when I send one packet with 64K, then TCP has divided 64K, not passed
> the whole 64K to NIC driver.
[...]

I think you won't see 64K packets for a TCP connection that was just
opened, due to the slow start algorithm.

Ben.

-- 
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.
