From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: add ip to interface as primary ip address, not secondary ip
 when there is alreadly primary ip?
Date: Wed, 18 Sep 2013 00:29:40 +0000 (UTC)
Message-ID: <l1as5j$7cs$1@ger.gmane.org>
References: <CAK3+h2zPYYLaVs-WhHFaDhOsnLBB7m8vDvkTj5a16FUJ02i4KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56910 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754066Ab3IRAaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 20:30:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VM5ea-00078t-Ir
	for netdev@vger.kernel.org; Wed, 18 Sep 2013 02:30:00 +0200
Received: from 117.57.109.102 ([117.57.109.102])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 02:30:00 +0200
Received: from xiyou.wangcong by 117.57.109.102 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 02:30:00 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Sep 2013 at 22:31 GMT, Vincent Li <vincent.mc.li@gmail.com> wrote:
>
> ideally though, we would like to have the capability in
> kernel/userspace  to specify a flag or something to add any ip as
> primary even if there is already existing primary ip address (could
> downgrade the existing primary to secondary ip). does this make sense
> ?

'ip addr' already has flags for this.
