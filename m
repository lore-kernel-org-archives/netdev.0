From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 3/3] net: ipv6: Implement /proc/net/icmp6.
Date: Wed, 29 May 2013 03:15:24 +0000 (UTC)
Message-ID: <ko3rsc$qss$1@ger.gmane.org>
References: <1369752315-11167-1-git-send-email-lorenzo@google.com>
 <1369752315-11167-3-git-send-email-lorenzo@google.com>
 <CAKD1Yr0YXy+xoE4rVRFmd6pQbE+biw+8008Nd_VbyaSMn8c9+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:46565 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759194Ab3E2DPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 23:15:42 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UhWrU-0001sv-K8
	for netdev@vger.kernel.org; Wed, 29 May 2013 05:15:40 +0200
Received: from 180.183.217.220 ([180.183.217.220])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 05:15:40 +0200
Received: from xiyou.wangcong by 180.183.217.220 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 05:15:40 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 at 02:31 GMT, Lorenzo Colitti <lorenzo@google.com> wrote:
> I don't think this has any impact, because if this happens, the proto
> isn't registered, so there's no way to create an IPv6 socket and call
> these function pointers. Still, for completeness' sake I'll shortly
> send out another patch 3/3 that checks the result of
> register_pernet_subsys before updating the function pointers. The
> other two patches in the set don't need to change.

You have to resend all of them, not just one, per netdev rules.
