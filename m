From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] bonding: Use notifiers for slave link state
 detection
Date: Mon, 25 Jan 2016 16:37:11 +0000
Message-ID: <87618083B2453E4A8714035B62D679925051E55D@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
 <1453371388-30230-1-git-send-email-zyjzyj2000@gmail.com>
 <1453371388-30230-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"jay.vosburgh@canonical.com" <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27393 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280AbcAYQhP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 11:37:15 -0500
In-Reply-To: <1453371388-30230-2-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: zyjzyj2000@gmail.com [mailto:zyjzyj2000@gmail.com]
>Sent: Thursday, January 21, 2016 2:16 AM
>To: zyjzyj2000@gmail.com; mkubecek@suse.cz; vfalico@gmail.com;
>gospo@cumulusnetworks.com; netdev@vger.kernel.org; Shteinbock, Boris (Wind
>River); jay.vosburgh@canonical.com; Tantilov, Emil S
>Subject: [PATCH 1/1] bonding: Use notifiers for slave link state detection
>
>From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
>Bonding will utilize notifier callbacks to detect slave
>link state changes. It is intended to be used with miimon
>set to zero, and does not support the updelay or downdelay
>options to bonding.
>
>Because of link flap from the slave interface, if the notifier
>is NETDEV_UP while the actual link state is down, it is not
>necessary to continue.
>
>Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>Tested-by: Tantilov, Emil S <emil.s.tantilov@intel.com>
>Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
>---
> drivers/net/bonding/bond_main.c |  317 +++++++++++++++++++++--------------
>----
> 1 file changed, 170 insertions(+), 147 deletions(-)

Just for the record - this is not a patch that I have tested.

I did run tests with the patch Jay Vosburgh submitted for introducing
notifiers and that is handled in a separate thread.

Why do you keep re-sending Jay's patches?

Thanks,
Emil
