From: Steve.Glendinning@smsc.com
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 08:54:36 +0000
Message-ID: <OF8C316D93.937F4899-ON8025753E.0030604F-8025753E.003106B3@smsc.com>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: "Stanley.Miao" <stanley.miao@windriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3172 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752805AbZANI4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 03:56:07 -0500
In-Reply-To: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When calling request IRQ it is desirable to allow platforms
> to specific flags for the call to request_irq. Adding irq_flags
> to smsc911x_platform_config allows these flags to be passed.
> 
> Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Thanks Stanley.

I have two more arm platform smsc911x conversion patches (realview and 
pcm037) which I'll post for review shortly.  Both also depend on this 
irq_flags change, as they register their interrupts shared.  David: would 
it make sense to put this driver patch into the arm tree?

Steve
