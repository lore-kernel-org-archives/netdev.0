From: kbuild test robot <lkp@intel.com>
Subject: Re: [RFT v2] geneve: implement support for IPv6-based tunnels
Date: Thu, 1 Oct 2015 02:07:44 +0800
Message-ID: <201510010225.XnxAY8Ox%fengguang.wu@intel.com>
References: <1443632696-9900-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	davem@davemloft.net, "John W. Linville" <linville@tuxdriver.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932190AbbI3SJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 14:09:26 -0400
Content-Disposition: inline
In-Reply-To: <1443632696-9900-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

[auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]

reproduce:
  # apt-get install sparse
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/geneve.c:55:19: sparse: symbol 'geneve_remote_unspec' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
