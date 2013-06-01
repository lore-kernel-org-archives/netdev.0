From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next]  igmp: remove useless (void) cast
Date: Sat, 1 Jun 2013 02:51:05 +0000 (UTC)
Message-ID: <kobnip$gat$1@ger.gmane.org>
References: <20130531184438.21966f63@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36759 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224Ab3FACvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 22:51:23 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uibub-0003uf-Uh
	for netdev@vger.kernel.org; Sat, 01 Jun 2013 04:51:21 +0200
Received: from 14.207.174.130 ([14.207.174.130])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 04:51:21 +0200
Received: from xiyou.wangcong by 14.207.174.130 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 04:51:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 01 Jun 2013 at 01:44 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
> Back in the old Unix lint days, it was common to put (void) in front
> of functions when return value was being ignored. Now this is considered
> unnecessary, catch up with the fashion.
>

None of the callers of ip_mc_leave_src() checks its return value, so I
think we can just make it void.
