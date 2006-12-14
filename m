From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the
 latest API draft.
Date: Wed, 13 Dec 2006 18:03:40 -0800 (PST)
Message-ID: <20061213.180340.26278674.davem@davemloft.net>
References: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
	<20061213.163554.63998920.davem@davemloft.net>
	<1166060332.4670.37.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbWLNCDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 21:03:46 -0500
To: sri@us.ibm.com
In-Reply-To: <1166060332.4670.37.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 13 Dec 2006 17:38:52 -0800

> These parameters are not used by user-space apps. They define the
> parameters used by the protocol in SCTP headers that go on wire.

There is no __KERNEL__ ifdef protection for these defines,
and the linux/sctp.h header is exported to userspace via
include/linux/Kbuild, therefore the interface is exposed to
userspace and you cannot break it.

Those are the facts.

Your lksctp tool package might provide an alternative header,
that's fine, but it doesn't change the situations with respect
to linux/sctp.h
