From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: vhost-net-next updates
Date: Thu, 4 Nov 2010 13:26:30 +0200
Message-ID: <20101104112630.GA28748@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728Ab0KDL0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 07:26:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I pushed out some optimization patches on vhost-net-next
branch on my vhost tree (intended for 2.6.38).
It would be helpful if people working on vhost-net optimizations
base their work on that tree just to make sure comparisons
are apples to apples.

I might rebase this as I didn't send a pull request to Dave yet
but I'll try not to.  So far I have:

8b7347a vhost: get/put_user -> __get/__put_user
dfe5ac5 vhost: copy_to_user -> __copy_to_user
64e1c80 vhost-net: batch use/unuse mm
533a19b vhost: put mm after thread stop
3fcedec drivers/vhost/vhost.c: delete double assignment

Thanks!

-- 
MST
