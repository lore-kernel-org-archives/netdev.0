From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] [IPV4] SNMP: Display new statistics at
 /proc/net/snmp
Date: Fri, 27 Apr 2007 16:46:30 +0900
Message-ID: <20070427164630.3160ded5.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
	<20070417201436.ab8f3f7a.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46085 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120AbXD0Hqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 03:46:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3R7kiAj028111
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 03:46:44 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3R7kib9532914
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 03:46:44 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3R7kipR005722
	for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 03:46:44 -0400
In-Reply-To: <20070417201436.ab8f3f7a.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Apr 2007 20:14:36 +0900
Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:

> This displays the statistics specified in the updated IP-MIB RFC
> (RFC4293) at /proc/net/snmp. As new statistics are placed as the
> last elements, this change wouldn't affect netstat, net-snmp, etc.

I'm sorry. I found adding new entries to /proc/net/snmp affects
net-snmp. I'm ashamed of my inadequate investigation.

However the other patches to support new statistics will be useful.
Could you pick up 1st to 5th patches?

Thank you,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>

