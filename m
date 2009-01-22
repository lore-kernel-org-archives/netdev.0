From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 7/8] arm: convert omap ldp platform to use smsc911x
Date: Thu, 22 Jan 2009 10:58:10 +0000
Message-ID: <20090122105810.GD32153@n2100.arm.linux.org.uk>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com> <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, steve.glendinning@smsc.com
To: "Stanley.Miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:36397 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbZAVK63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 05:58:29 -0500
Content-Disposition: inline
In-Reply-To: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 11:06:09AM +0800, Stanley.Miao wrote:
> -	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
> -	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
> +	ldp_smsc911x_resources[0].start = cs_mem_base + 0x0;
> +	ldp_smsc911x_resources[0].end   = cs_mem_base + 0x100;

This doesn't look right - 'end' is inclusive not exclusive.  So this
reserves 257 bytes, not 256 bytes.
