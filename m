From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK 01/04]: Switch cb_lock spinlock to mutex and allow to
 override it
Date: Mon, 16 Apr 2007 16:55:54 -0700 (PDT)
Message-ID: <20070416.165554.55726278.davem@davemloft.net>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
	<20070416074950.19262.97555.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbXDPXzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 19:55:52 -0400
In-Reply-To: <20070416074950.19262.97555.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 09:51:53 +0200 (MEST)

> [NETLINK]: Switch cb_lock spinlock to mutex and allow to override it
> 
> Switch cb_lock to mutex and allow netlink kernel users to override it
> with a subsystem specific mutex for consistent locking in dump callbacks.
> All netlink_dump_start users have been audited not to rely on any
> side-effects of the previously used spinlock.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.

The call signature of netlink_kernel_create() is getting huge.
It's getting near the time we should pass in a descriotor
block in the form of a structure to specify all of these
parameters.

It would have even made this patch significantly smaller since the
default of NULL would have worked out perfectly.
