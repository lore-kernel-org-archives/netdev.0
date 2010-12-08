From: Ilya Loginov <isloginov@gmail.com>
Subject: Re: WARNING at local_bh_enable while tcp_retransmit
Date: Wed, 8 Dec 2010 12:36:45 +0300
Message-ID: <20101208123645.84091844.isloginov@gmail.com>
References: <20101207182308.664e171d.isloginov@gmail.com>
	<4CFE9F73.1040203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62103 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab0LHJeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 04:34:16 -0500
Received: by wyb28 with SMTP id 28so874248wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 01:34:15 -0800 (PST)
In-Reply-To: <4CFE9F73.1040203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Dec 2010 21:56:19 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> Hi, isn't any of your drivers disabling irqs on this path?

No. But we are in soft_irq because tcp_retransmit. So, may be,
interrupts were really disabled.

> (If no, what is the kernel version?)
> 
> Jarek P.

2.6.34. But this does not matter.

I am afraid of this is common problem in all network drivers using
dev_queue_xmit (for example bonding). I didn't see this problem before,
while I have no retransmits.

-- 
Ilya Loginov <isloginov@gmail.com>
