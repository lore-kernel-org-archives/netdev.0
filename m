From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] move flow control definitions to mii.h
Date: Wed, 17 Dec 2008 16:27:19 -0800 (PST)
Message-ID: <20081217.162719.132693546.davem@davemloft.net>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	<1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
	<20081217161708.cb83783c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	ian.saturley@smsc.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751742AbYLRA1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:27:18 -0500
In-Reply-To: <20081217161708.cb83783c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 17 Dec 2008 16:17:08 -0800

> On Sun, 14 Dec 2008 12:38:20 +0000
> Steve Glendinning <steve.glendinning@smsc.com> wrote:
> 
> > flags used within drivers for indicating tx and rx flow control are
> > defined in 4 drivers (and probably more), move these constants to mii.h.
> > 
> > The 3 SMSC drivers use the same constants (FLOW_CTRL_TX), but TG3 uses
> > TG3_FLOW_CTRL_TX, so this patch also renames the constants within TG3.
> > 
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> > ---
> >  drivers/net/smsc911x.h     |    3 --
> >  drivers/net/smsc9420.h     |    3 --
> >  drivers/net/tg3.c          |   50 ++++++++++++++++++++++----------------------
> >  drivers/net/tg3.h          |    2 -
> >  drivers/net/usb/smsc95xx.c |    2 -
> >  include/linux/mii.h        |    4 +++
> 
> In file included from drivers/net/bnx2.c:52:
> drivers/net/bnx2.h:6851:1: warning: "FLOW_CTRL_TX" redefined
> In file included from drivers/net/bnx2.c:37:
> include/linux/mii.h:139:1: warning: this is the location of the previous definition
> In file included from drivers/net/bnx2.c:52:
> drivers/net/bnx2.h:6852:1: warning: "FLOW_CTRL_RX" redefined
> 
> There are unfixed definitions of FLOW_CTRL_TX in drivers/net/bnx2.h and
> drivers/net/bnx2x_link.h.

Already pointed out by Stephen Rothwell yesterday and fixed in
my tree 10 minutes later.
