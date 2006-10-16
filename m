From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Mon, 16 Oct 2006 11:50:42 -0700
Message-ID: <200610161850.k9GIogZt028527@death.nxdomain.ibm.com>
References: <200610162021.12884.dpc@asn.pl> <200610162027.15100.dpc@asn.pl>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:62879 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1422796AbWJPSup
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 14:50:45 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9GIoiAx023891
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 14:50:44 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9GIoi7m241716
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 12:50:44 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9GIoh0m000880
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 12:50:44 -0600
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-reply-to: <200610162027.15100.dpc@asn.pl> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dawid Ciezarkiewicz <dpc@asn.pl> wrote:
[...]
>+	weighted-rr or 7
>+
>+		Weighted round-robin bonding. In this mode bonding
>+		interface will use weights assigned to it's slaves.
>+
>+		Each slave can have weight assigned via ioctl (ifenslave).
>+		These values will be used at the start of each "cycle".
>+		Each slave will have token counter restored to it's weight.
>+		Then using round-robin mechanism those tokens are "used"
>+		to pay for emitted frames. When all token counters are
>+		zeroed - new "cycle" begins.

	Before getting into the technical bits of the patch, what's the
reason for wanting to do this, and why is this rather complex manual
weight assignment better than an automatic system based on, e.g., link
speed of the slaves?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
