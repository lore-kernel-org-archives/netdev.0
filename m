From: Michal Kubecek <mkubecek@suse.cz>
Subject: please queue commit ac37e2515c1a for stable 3.12 - 3.18
Date: Thu, 4 Jun 2015 22:54:03 +0200
Message-ID: <20150604205403.GA24969@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

please queue mainline commit

  ac37e2515c1a ("xfrm: release dst_orig in case of error in xfrm_lookup()")

for stable branches 3.12, 3.14 and 3.18. It fixes a dst_entry reference
leak introduced by commit

  f92ee61982d6 ("xfrm: Generate blackhole routes only from route lookup functions")

present in these branches (3.12 and 3.14 as a backport, 3.18 from
mainline). The patch applies cleanly to all three and I tested that it
fixes the issue in 3.12.

                                                         Michal Kubecek
