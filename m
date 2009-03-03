From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol
 identifer
Date: Tue, 03 Mar 2009 14:17:49 -0800 (PST)
Message-ID: <20090303.141749.210780391.davem@davemloft.net>
References: <20090303170014.GB1480@hmsreliant.think-freely.org>
	<20090303182006.GB29236@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762196AbZCCWSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:18:07 -0500
In-Reply-To: <20090303182006.GB29236@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Tue, 3 Mar 2009 21:20:06 +0300

> Why do you want to use own family instead of using existing netlink
> helpers like connector or genetlink?

Yes, indeed, use genetlink for this.

We don't add new core netlink protocols any more with it's
fixed address space of link types.
