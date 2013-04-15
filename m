From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi-
 and broadcasts
Date: Mon, 15 Apr 2013 16:58:02 +0000 (UTC)
Message-ID: <kkhbiq$5bu$1@ger.gmane.org>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52500 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117Ab3DOQ6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 12:58:14 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1URmjM-0007vw-D8
	for netdev@vger.kernel.org; Mon, 15 Apr 2013 18:58:12 +0200
Received: from 216-75-227-12.static.wiline.com ([216.75.227.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 18:58:12 +0200
Received: from xiyou.wangcong by 216-75-227-12.static.wiline.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 18:58:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Apr 2013 at 09:21 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
> and therefore will be sent out bypassing encapsulation. This breaks
> delivery of packets sent to the vxlan multicast group.
> Disabling encapsulation bypass for multicasts and broadcasts fixes the
> issue.
>
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

This fixes the regression I reported.

Tested-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
