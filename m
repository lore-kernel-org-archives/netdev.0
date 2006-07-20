From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] Qlogic qla3xxx driver v2.02.00-k36 for upstream inclusion.
Date: Thu, 20 Jul 2006 18:59:28 +0400
Message-ID: <44BF9A50.60207@tls.msk.ru>
References: <0BB3E5E7462EEA4295BC02D49691DC07223E4E@AVEXCH1.qlogic.org> <20060720145025.GA305@andrew-vasquezs-powerbook-g4-15.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:64603 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932588AbWGTO7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 10:59:32 -0400
To: Andrew Vasquez <andrew.vasquez@qlogic.com>
In-Reply-To: <20060720145025.GA305@andrew-vasquezs-powerbook-g4-15.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Vasquez wrote:
> On Thu, 20 Jul 2006, Ron Mercer wrote:
> 
>> qla3xxx driver  does not support ISP4010.
> 
> Exactly...  The qla3xxx driver supports the NIC function only.

...which is provided by ISP4010 card, as appears on PCI bus:

04:04.0 Ethernet controller: QLogic Corp. QLA3010 Network Adapter (rev 05)
04:04.1 Network controller: QLogic Corp. QLA4010 iSCSI TOE Adapter (rev 05)

(the first (sub)device).  So it *looks* like the card has *both*
a NIC and iSCSI TOE adapter, and the NIC part is pretty much similar
to what qla3xxx driver expects...  That's why my curiosity. ;)

(not that it matters much, just.. curious, really.
Well.  Not exactly.  It'd be nice to compare a NIC w/o Jumbo
frames support (which we have on all machines connected to
the iSCSI segment), with something more.. advanced.  So I
wondered if I can utilize the NIC part of the ISP4010 for
the test.  iSCSI part of the card works significantly slower
than open-iscsi stack on non-jumbo-frames-aware Tigon GigE NIC).

[]
> You'll need to use the qla4xxx driver to drive the iSCSI function.

Yeah, I know.  I posted some results to open-iscsi@ list about a week
ago.  It basically works (the new one, with open-iscsi infrastructure),
but is slooow... ;)

Thanks.

/mjt
