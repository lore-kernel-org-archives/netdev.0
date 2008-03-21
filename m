From: "Keyur Chudgar" <kchudgar.linux@gmail.com>
Subject: Question regarding netif_tx_disable and netif_stop_queue
Date: Fri, 21 Mar 2008 15:09:32 -0700
Message-ID: <a967d7d00803211509g3154f996jc7f0337fd56e0c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.243]:54639 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbYCUWJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:09:34 -0400
Received: by ag-out-0708.google.com with SMTP id 35so2988540aga.10
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 15:09:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am writing a device driver for new emac hardware. I have a question regarding
netif_tx_disable and netif_stop_queue.

If the Emac hardware's queue is full and I need to assist the kernel with
stopping the packet scheduling from kernel, which function should
I use, if I am invoking it from outside of hard_start_xmit method?
Probably it will
be from the interrupt context or polling routine. From the review, I
understand that
I should use netif_tx_disable(struct net_device *dev); and not use
netif_stop_queue
(this function is generally used from within hard_start_xmit). I think
netif_tx_disable
is more suitable for SMP environment also, as it takes care for
hard_start_xmit method
is not running on another CPU. But I just would like to make sure about it.

Thanks,
- Keyur
