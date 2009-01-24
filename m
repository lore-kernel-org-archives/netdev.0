From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH 7/8] arm: convert omap ldp platform to use smsc911x
Date: Sat, 24 Jan 2009 12:14:18 +0800
Message-ID: <1232770458.18235.1.camel@localhost>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
	 <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
	 <20090122105810.GD32153@n2100.arm.linux.org.uk>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, steve.glendinning@smsc.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48574 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbZAXEF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2009 23:05:29 -0500
In-Reply-To: <20090122105810.GD32153@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 10:58 +0000, Russell King - ARM Linux wrote:
> On Wed, Jan 21, 2009 at 11:06:09AM +0800, Stanley.Miao wrote:
> > -	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
> > -	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
> > +	ldp_smsc911x_resources[0].start = cs_mem_base + 0x0;
> > +	ldp_smsc911x_resources[0].end   = cs_mem_base + 0x100;
> 
> This doesn't look right - 'end' is inclusive not exclusive.  So this
> reserves 257 bytes, not 256 bytes.

Thanks for the review, correct it.

Stanley.
