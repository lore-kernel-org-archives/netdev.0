From: James Chapman <jchapman@katalix.com>
Subject: Re: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Mon, 03 Sep 2007 14:33:35 +0100
Message-ID: <46DC0D2F.2040902@katalix.com>
References: <46DBE393.30300@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: John Sigler <linux.kernel@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33777 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbXICNdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 09:33:38 -0400
In-Reply-To: <46DBE393.30300@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Sigler wrote:
> 
> Hello everyone,
> 
> I have several systems with three integrated Intel 82559 (I *think*).
> 
> Does someone know if these boards support hardware interrupt mitigation?

82558/9 hardware does, sort of. But the e100 driver doesn't use it 
because it uses NAPI to minimize rx & tx interrupts.

> I.e. is it possible to configure them to raise an IRQ only if their
> hardware buffer is full OR if some given time (say 1 ms) has passed and
> packets are available in their hardware buffer.
> 
> I've been using the eepro100 driver up to now, but I'm about to try the
> e100 driver. Would I have to use NAPI? Or is this an orthogonal feature?

Use NAPI. The e100 driver has been NAPI-only for a while.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


