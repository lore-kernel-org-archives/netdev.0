From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next-2.6 5/6] bonding: get rid of IFF_SLAVE_INACTIVE
 netdev->priv_flag
Date: Mon, 14 Mar 2011 05:29:35 +0000 (UTC)
Message-ID: <ilk93u$ant$1@dough.gmane.org>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
	<1299935679-18135-6-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52774 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510Ab1CNF3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 01:29:53 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Pz0Lj-00007s-FE
	for netdev@vger.kernel.org; Mon, 14 Mar 2011 06:29:47 +0100
Received: from 180.106.106.40 ([180.106.106.40])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 06:29:47 +0100
Received: from xiyou.wangcong by 180.106.106.40 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 06:29:47 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Mar 2011 14:14:38 +0100, Jiri Pirko wrote:

> Since bond-related code was moved from net/core/dev.c into bonding,
> IFF_SLAVE_INACTIVE is no longer needed. Replace is with flag "inactive"
> stored in slave structure
> 

Good work, Jiri!

IFF_ flags are valuable and are going to be exhausted, moving
these slave-specific flags to struct slave is indeed good.

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

