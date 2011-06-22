From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 07:55:20 +0000 (UTC)
Message-ID: <its758$adj$1@dough.gmane.org>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:34204 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975Ab1FVHzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 03:55:43 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QZIHi-0006ey-7f
	for netdev@vger.kernel.org; Wed, 22 Jun 2011 09:55:41 +0200
Received: from 202.106.149.182 ([202.106.149.182])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 09:55:38 +0200
Received: from xiyou.wangcong by 202.106.149.182 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 09:55:38 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 09:00:40 -0400, Prarit Bhargava wrote:

> Add Network Sysrq Support
> 
> In some circumstances, a system can hang/lockup in such a way that the
> system is completely unresponsive to keyboard or console input but is
> still responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> net/ipv4/sysrq-ping.ko which allows a root user to configure the system
> for a remote sysrq.
> 

Cool work, Prarit! Now we have remote sysrq!

I am just wondering why the module is in net/ipv4/sysrq-ping.c?
Not drivers/net/sysrq-ping.c? or perhaps net/core/sysrq-ping.c?
I understand it only supports IPv4 now, but we can add IPv6 support,
can't we? ;)

Thanks!

