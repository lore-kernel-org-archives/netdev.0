From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] vxlan: use htonl when snooping for loopback
 address
Date: Sun, 14 Apr 2013 15:07:37 +0000 (UTC)
Message-ID: <kkegnp$4jj$2@ger.gmane.org>
References: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53984 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab3DNPHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 11:07:50 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UROWw-0007nr-O8
	for netdev@vger.kernel.org; Sun, 14 Apr 2013 17:07:46 +0200
Received: from 216-75-227-12.static.wiline.com ([216.75.227.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 17:07:46 +0200
Received: from xiyou.wangcong by 216-75-227-12.static.wiline.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 17:07:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Apr 2013 at 09:21 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> Currently "bridge fdb show dev vxlan0" lists loopback address as
> "1.0.0.127". Using htonl(INADDR_LOOPBACK) rather than passing it
> directly to vxlan_snoop fixes the problem.
>
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>

Good catch!

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
