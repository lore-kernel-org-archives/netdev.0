From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 09:21:26 -0800 (PST)
Message-ID: <20071211.092126.151519334.davem@davemloft.net>
References: <20071211163019.15059.73746.stgit@flek.lan>
	<20071211.090611.59888503.davem@davemloft.net>
	<200712111215.00720.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751174AbXLKRV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:21:26 -0500
In-Reply-To: <200712111215.00720.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 11 Dec 2007 12:15:00 -0500

> I still would like to see the rest of the changes make it into
> 2.6.25 (the SPI byte order thing is particularly troublesome) so if
> you don't mind a "v3" I'll respin this patch right now to remove the
> "sid -> secid" bits.

Technically this could break anything parsing the audit logs, but no
matter, I'd rather fix this now while we still can.

I would classify the spi endianness bit as a bug fix, could you please
just split out that fix for net-2.6, then we can make a second patch
after I rebase net-2.6.25 which can do the rest of your patch sans the
linux/xfrm.h change?

Thanks.

