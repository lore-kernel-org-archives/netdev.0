From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 10:19:46 +0000
Message-ID: <20090114101946.GE22976@n2100.arm.linux.org.uk>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com> <OF8C316D93.937F4899-ON8025753E.0030604F-8025753E.003106B3@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Stanley.Miao" <stanley.miao@windriver.com>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:55356 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbZANKUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:20:04 -0500
Content-Disposition: inline
In-Reply-To: <OF8C316D93.937F4899-ON8025753E.0030604F-8025753E.003106B3@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 08:54:36AM +0000, Steve.Glendinning@smsc.com wrote:
> I have two more arm platform smsc911x conversion patches (realview and 
> pcm037) which I'll post for review shortly.  Both also depend on this 
> irq_flags change, as they register their interrupts shared.  David: would 
> it make sense to put this driver patch into the arm tree?

BTW, the shared-ness of an interrupt handler depends on how the interrupt
handler is written, not on whether you require the interrupt to be
exclusively owned or not.

So, if a driver is written to co-operate properly with shared interrupts
then it should always pass IRQF_SHARED.
