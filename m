From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments
 in non-debug build
Date: Tue, 20 Jan 2009 09:19:47 -0800 (PST)
Message-ID: <20090120.091947.228093214.davem@davemloft.net>
References: <200901192111.48432.david-b@pacbell.net>
	<OF3908A70A.0C947A82-ON80257544.003AA7DB-80257544.003C295C@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, ian.saturley@smsc.com, jeff@garzik.org,
	jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45222
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757297AbZATRTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 12:19:45 -0500
In-Reply-To: <OF3908A70A.0C947A82-ON80257544.003AA7DB-80257544.003C295C@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Tue, 20 Jan 2009 10:56:09 +0000

> I've fixed this compilation breakage now, updated patchset to
> follow.

But you added a new warning for the non-DEBUG case during the
intermediate steps between the patches.

Please respin this all into a single patch in order to make the
transition cleanly, for all cases.
