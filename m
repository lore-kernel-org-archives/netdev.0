From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Thu, 21 Jan 2010 18:03:11 -0800 (PST)
Message-ID: <20100121.180311.228791894.davem@davemloft.net>
References: <1264039999-25731-3-git-send-email-agust@denx.de>
	<20100121.012235.161201297.davem@davemloft.net>
	<4B5871F2.9090005@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	jcrigby@gmail.com, kosmo@semihalf.com, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60124
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751969Ab0AVCDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 21:03:00 -0500
In-Reply-To: <4B5871F2.9090005@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 21 Jan 2010 16:25:38 +0100

> Do you see a more clever solution to this problem?

See how we handle this in the ESP scsi driver.  We have a set of
defines for the register offsets, and a set of methods a chip driver
implements for register accesses.

If the offsets differ, the register access method can translate the
generic register offsets into whatever layout their implementation
actually uses.

> Nevertheless, the code could be improved by using "offsetof", I
> think.

At a minimum :-)
