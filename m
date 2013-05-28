From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: allow specifying multiple
 default destinations
Date: Tue, 28 May 2013 08:46:20 +0000 (UTC)
Message-ID: <ko1qss$gu8$1@ger.gmane.org>
References: <1369729878-9690-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369729878-9690-3-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41386 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933576Ab3E1Iqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:46:37 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UhFYC-0004Es-R3
	for netdev@vger.kernel.org; Tue, 28 May 2013 10:46:36 +0200
Received: from 180.183.220.200 ([180.183.220.200])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 10:46:36 +0200
Received: from xiyou.wangcong by 180.183.220.200 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 10:46:36 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 at 08:31 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> +	IFLA_VXLAN_REMOTE_ADD,
> +	IFLA_VXLAN_REMOTE_DEL,
> +	IFLA_VXLAN_REMOTE_LST,

Usually we use NEW_* and GET_* instead of *_ADD and *_LST.
