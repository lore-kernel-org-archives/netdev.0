From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Tue, 8 Mar 2011 12:51:54 +0000 (UTC)
Message-ID: <il58p9$3ka$2@dough.gmane.org>
References: <4D75D244.9070409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:49995 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175Ab1CHMwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 07:52:09 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PwwOS-0006Z3-UD
	for netdev@vger.kernel.org; Tue, 08 Mar 2011 13:52:08 +0100
Received: from 123.135.217.68 ([123.135.217.68])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:52:04 +0100
Received: from xiyou.wangcong by 123.135.217.68 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:52:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Mar 2011 14:52:52 +0800, Weiping Pan wrote:

> ok, I use "Host-only mode" and get
> 
> 
> 
> an conclusion, that if the first enslaved nic is pulled out, bonding
> can't handle well.
> 
> First test.
> I first enslave eth6, then pull it out, bonding doesn't work. on host,
...
> 
> 
> Second test
> I first enslave eth6, then pull eth7 out, bonding works well. on guest,

Can you show me your /proc/net/bonding/bond0 before and after pulling down
eth6 or eth7? And what does `ip link show` say?

