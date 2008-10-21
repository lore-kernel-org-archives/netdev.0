From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver
	on	RealView
Date: Tue, 21 Oct 2008 11:42:06 +0100
Message-ID: <1224585726.9330.22.camel@pc1117.cambridge.arm.com>
References: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bill Gatliff <bgat@billgatliff.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:63647 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751552AbYJUKmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 06:42:45 -0400
In-Reply-To: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-21 at 11:26 +0100, Steve.Glendinning@smsc.com wrote:
> The smsc911x driver is still maintained (out of tree), and is used by many
> of our customers.  Mainline inclusion is still very much the intention!
> 
> Almost all the feedback I've had has been positive, but I've had a few
> "can't you just fix the in-tree driver?" responses.  The trouble is it's
> not a *small* piece of work!

Can we not have both drivers in the kernel until the transition to the
new one has finished? We seem to still have both eepro100.c and e100.c
in the kernel targeting similar chips.

-- 
Catalin

