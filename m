From: "Majid Khan" <majidkk@gmail.com>
Subject: Interrupt handling on SMP system
Date: Wed, 14 Jun 2006 13:20:40 -0400
Message-ID: <a656c20606141020w14665137lf74b50ce67aa5fce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:28305 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750941AbWFNRUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 13:20:41 -0400
Received: by py-out-1112.google.com with SMTP id i49so433521pye
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 10:20:40 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
  I had a few question regarding how interrupt handling work on linux
within a SMP systems.

1. Which processor gets the interrupt when a new packet arrives? Is
there any policy mechanism which can guide the interrupt to the idle
processor etc? Do the processors share an interrupt line and an
interrupt controller assign it to a specific processor?

2. When a soft IRQ is scheduled by the driver and picked up by a
ksoftirqd thread, does it get processed entirely on the same
processor? Does ksoftirqd/i thread processes the packets in the ith
processor queue only?

Regards,
Majid
