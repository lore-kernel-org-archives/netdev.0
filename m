From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 01/10] smc91x: remove unused code enclosed by #ifdef CONFIG_ISA
 .. #endif
Date: Fri, 27 Jun 2008 14:10:47 +0800
Message-ID: <48648467.1080308@gmail.com>
References: <> <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com> <486480E6.8070804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@cam.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:31360 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759208AbYF0GK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 02:10:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so404304rvb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 23:10:57 -0700 (PDT)
In-Reply-To: <486480E6.8070804@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Eric Miao wrote:
>> Apparently, the code enclosed by #ifdef CONFIG_ISA .. #endif are no
>> longer
>> used
> 
> What does this mean?
> 
> CONFIG_ISA platforms still exist, and one presumes that the ISA hardware
> still exists.
> 
> Is this hardware covered by another driver?
> 

Well, I assume the original code tends to support ISA with module
parameters to setup the IO address base and IRQ etc. But obviously,
those part of the code is now totally invalid and confusing only.

Should there be requirement of supporting ISA hardware with this
chip, the driver is actually unable to, and I prefer to re-write
that part of the code if necessary.

BTW: I don't know any ISA NIC with a SMC91X chip by far, and I
cannot infer by the driver code itself what type of ISA NIC it
is supporting.
