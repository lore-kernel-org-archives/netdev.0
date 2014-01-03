From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Fri, 3 Jan 2014 04:56:36 +0000 (UTC)
Message-ID: <slrnlccgog.3uh.xiyou.wangcong@linux-6brj.site>
References: <1388653054-4341-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37639 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaACFAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:00:05 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Vywrc-0005QY-21
	for netdev@vger.kernel.org; Fri, 03 Jan 2014 06:00:04 +0100
Received: from c-67-170-205-66.hsd1.ca.comcast.net ([67.170.205.66])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 06:00:04 +0100
Received: from xiyou.wangcong by c-67-170-205-66.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 06:00:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Jan 2014 at 08:57 GMT, roy.qing.li@gmail.com <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> They are same, so unify them as one, pcpu_tstats.
> and move pcpu_tstat into netdevice.h
>

tstats means Tunnel Stats, right? So you can't move
it to netdevice.h.
