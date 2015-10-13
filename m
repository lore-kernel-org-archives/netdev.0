From: "Singh, Krishneil K" <krishneil.k.singh@intel.com>
Subject: RE: [PATCH v8 1/3] if_link: Add control trust VF
Date: Tue, 13 Oct 2015 16:12:16 +0000
Message-ID: <EF50CC0C76A53A44BAD798C58E0A157E271E74A8@ORSMSX103.amr.corp.intel.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05F28E5B@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12576 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932547AbbJMQMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 12:12:19 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05F28E5B@BPXM14GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Hiroshi Shimamoto
Sent: Thursday, August 27, 2015 11:58 PM
To: Or Gerlitz <gerlitz.or@gmail.com>; Alexander Duyck <alexander.duyck@gmail.com>; Skidmore, Donald C <donald.c.skidmore@intel.com>; Rose, Gregory V <gregory.v.rose@intel.com>; Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-lan@lists.osuosl.org; nhorman@redhat.com; jogreene@redhat.com; Linux Netdev List <netdev@vger.kernel.org>; Choi, Sy Jong <sy.jong.choi@intel.com>; Rony Efraim <ronye@mellanox.com>; Edward Cree <ecree@solarflare.com>; David Miller <davem@davemloft.net>; sassmann@redhat.com
Subject: [Intel-wired-lan] [PATCH v8 1/3] if_link: Add control trust VF

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Add netlink directives and ndo entry to trust VF user.

This controls the special permission of VF user.
The administrator will dedicatedly trust VF user to use some features which impacts security and/or performance.

The administrator never turn it on unless VF user is fully trusted.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
CC: Choi, Sy Jong <sy.jong.choi@intel.com>
---
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
