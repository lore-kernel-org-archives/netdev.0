From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 0/4 net-next] enic: add devcmd2
Date: Fri, 21 Aug 2015 17:19:03 +0000
Message-ID: <253CF818969A9240AB2054BF91F2C2BC301A082C@ORSMSX114.amr.corp.intel.com>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
 <20150817.153832.1220000969996122058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nalreddy@cisco.com" <nalreddy@cisco.com>,
	"ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: David Miller <davem@davemloft.net>,
	"_govind@gmx.com" <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56804 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbbHURTG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 13:19:06 -0400
In-Reply-To: <20150817.153832.1220000969996122058.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces a compile error
drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_probe':
drivers/net/ethernet/cisco/enic/enic_main.c:2490:3: error: label 'err_out_vnic_unregister' used but not defined
   goto err_out_vnic_unregister;
   ^
scripts/Makefile.build:258: recipe for target 'drivers/net/ethernet/cisco/enic/enic_main.o' failed
make[5]: *** [drivers/net/ethernet/cisco/enic/enic_main.o] Error 1
scripts/Makefile.build:403: recipe for target 'drivers/net/ethernet/cisco/enic' failed
make[4]: *** [drivers/net/ethernet/cisco/enic] Error 2

Commit that introduced the issue:

commit 373fb0873d4325a7afa04aec29ced0c122d1f8a9
Author: Govindarajulu Varadarajan <_govind@gmx.com>
Date:   Sun Aug 16 01:44:54 2015 +0530

    enic: add devcmd2
