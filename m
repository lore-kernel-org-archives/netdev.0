From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: cxgb4 is broken in v4.12-rc1
Date: Tue, 16 May 2017 01:00:08 +0000
Message-ID: <CY4PR12MB1432CA69BD6B7AE335B5DBB2C1E60@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <f5966da1-44e7-ebf7-c5df-28f815a77424@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Bates <sbates@raithlin.com>,
        SWise OGC <swise@opengridcomputing.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Logan Gunthorpe <logang@deltatee.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0093.outbound.protection.outlook.com ([104.47.32.93]:48489
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750759AbdEPBAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 21:00:09 -0400
In-Reply-To: <f5966da1-44e7-ebf7-c5df-28f815a77424@deltatee.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Logan,

Thanks for reporting the issue I will try to reproduce this, btw what is th=
e firmware version
on your setup?.

Regards
Ganesh




From: Logan Gunthorpe <logang@deltatee.com>
Sent: Tuesday, May 16, 2017 4:06 AM
To: Ganesh GR
Cc: David S. Miller; Stephen Bates; SWise OGC; netdev@vger.kernel.org
Subject: BUG: cxgb4 is broken in v4.12-rc1
=A0  =20
Hi,

With rc1 my T62100-LP-CR no longer functions correctly. Everything
appears fine but the link never goes into the UP state. I have one peer
with an older (functioning) kernel and the other peer on rc1.

I've bisected to find this is the offending commit:

3bb4858fd: cxgb4: avoid disabling FEC by default

I've also attached a bisect log.

Let me know if you need anything else.

Thanks,

Logan
    =
