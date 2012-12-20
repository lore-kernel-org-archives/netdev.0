From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V4 07/13] bridge: Add vlan id to multicast groups
Date: Thu, 20 Dec 2012 08:05:46 +0000 (UTC)
Message-ID: <kaugsq$u30$2@ger.gmane.org>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
 <1355939304-21804-8-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41605 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049Ab2LTIF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 03:05:59 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tlb8t-0001QT-Ou
	for netdev@vger.kernel.org; Thu, 20 Dec 2012 09:06:11 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 09:06:11 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 09:06:11 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Dec 2012 at 17:48 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> Add vlan_id to multicasts groups so that we know which vlan
> each group belongs to and can correctly forward to appropriate vlan.
>

I think you need to export VID to user-space as well?
