From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Make vhost multi-threaded and associate each thread to its guest's
 cgroup
Date: Tue, 27 Jul 2010 23:42:54 +0300
Message-ID: <20100727204254.GA17947@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122Ab0G0UsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 16:48:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar,
I pushed a patchset with all known issues fixed,
on my vhost-net-next branch.

For now this ignores the cpu mask issue, addressing
only the cgroups issue.

Would appreciate testing and reports.

Thanks,
-- 
MST
