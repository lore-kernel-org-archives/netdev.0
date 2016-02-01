From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] ixgbe: get link speed as a slave nic unrelated with
 link up
Date: Mon, 1 Feb 2016 15:55:18 +0000
Message-ID: <87618083B2453E4A8714035B62D67992505210F8@FMSMSX105.amr.corp.intel.com>
References: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
 <1454311675-24676-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64911 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbcBAPzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 10:55:19 -0500
In-Reply-To: <1454311675-24676-2-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
>Sent: Sunday, January 31, 2016 11:28 PM
>To: zyjzyj2000@gmail.com; Tantilov, Emil S; Schmitt, Phillip J; Kirsher,
>Jeffrey T; netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net;
>Shteinbock, Boris (Wind River)
>Subject: [PATCH 1/1] ixgbe: get link speed as a slave nic unrelated with
>link up
>
>From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
>The commit 0e4d422f5f72 ("ixgbe: do not call check_link for ethtool
>in ixgbe_get_settings()") decreases the bonding failures. But the
>following time slice still results in a bonding failure.
>
>bonding                ixgbe
>  |                     |
>  |                    carrier_on
>  |                     |
>  |    <----------------|
> link_up                |
>  |                     |
>  |                    carrier_off
>  |                     |
> get_link_speed ------->|
>  |                     |

The driver does not set carrier_off unless the link is actually down.

Did you actually test this patch?

Thanks,
Emil
