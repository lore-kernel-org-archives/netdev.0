From: "Sam Hopkins" <s.a.hopkins@gmail.com>
Subject: Fwd: dma_skb_copy_datagram_iovec not EXPORTed
Date: Tue, 5 Jun 2007 10:56:58 -0400
Message-ID: <908954150706050756x2c7fbee0o9b9df550a09bffb7@mail.gmail.com>
References: <908954150706041006v2a429726yd267c06ab42a1107@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:11955 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176AbXFEO47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:56:59 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2260989wah
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 07:56:58 -0700 (PDT)
In-Reply-To: <908954150706041006v2a429726yd267c06ab42a1107@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm forwarding along a message sent to kernelnewbies as I was directed
to address my question to this list.  I am not a member of netdev, so
please copy me on all discussion of this topic.

Cheers,

Sam

---

Greetings,

I am a developer of the kernel AoE (ATA over Ethernet) driver.  I am
attempting to add dma offloading of data receive, following in TCP's
footsteps via config option NET_DMA.  There is a function in
net/core/user_dma.c, dma_skb_copy_datagram_iovec, that appears to be
exactly what I need, but this function is not EXPORTed for use by
external modules.

Since the NET_DMA option is documented as "Network: TCP receive copy
offload" perhaps it's just an oversight that anyone else might benefit
from it?

Cheers,

Sam
