From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH RESEND net-next v3 0/2] bonding: Fix some issues for fail_over_mac
Date: Tue, 04 Feb 2014 12:00:31 -0800
Message-ID: <15005.1391544031@death.nxdomain>
References: <52E3447B.6050206@huawei.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41429 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079AbaBDUAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Feb 2014 15:00:39 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 4 Feb 2014 15:00:38 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1FE7C38C805E
	for <netdev@vger.kernel.org>; Tue,  4 Feb 2014 15:00:34 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s14K0Xsb3277094
	for <netdev@vger.kernel.org>; Tue, 4 Feb 2014 20:00:34 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s14K0Xvf026101
	for <netdev@vger.kernel.org>; Tue, 4 Feb 2014 15:00:33 -0500
In-reply-to: <52E3447B.6050206@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong <dingtianhong@huawei.com> wrote:

>The parameter fail_over_mac only affect active-backup mode, if it was
>set to active or follow and works with other modes, just like RR or XOR
>mode, the bonding could not set all slaves to the master's address, it
>will cause the slave could not work well with master.
>
>v1->v2: According Jay's suggestion, that we should permit setting an option
>	at any time, but only have it take effect in active-backup mode, so
>	I add mode checking together with fail_over_mac during enslavement and
>	rebuild the patches.
>
>v2->v3: The correct way to fix the problem is that we should not add restrictions when
>    	setting options, just need to modify the bond enslave and removal processing
>    	to check the mode in addition to fail_over_mac when setting a slave's MAC during
>    	enslavement. The change active slave processing already only calls the fail_over_mac
>    	function when in active-backup mode.
>
>	Remove the cleanup patch because the net-next is frozen now.
>
>Regards
>Ding

	Both patches look good to me.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J
	
---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
