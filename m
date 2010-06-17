From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPv6 stops working after ethtool diagnostic
Date: Thu, 17 Jun 2010 17:51:39 +0800
Message-ID: <4C19F02B.3000503@cn.fujitsu.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63846 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757367Ab0FQJv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 05:51:57 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S wrote, at 06/16/2010 02:05 AM:
> We ran into a problem on net-next where IPv6 traffic fails after running ethtool -t:

When you execute "ethtool -t" or "ifdown", the router entry to fec0::1314 will be
deleted.

Try to add the router using the following command:
#ip -6 route add fec0::1314 dev eth1

-- 
Best Regards
-----
Shan Wei
