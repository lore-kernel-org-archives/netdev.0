From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] gigaset: return -ENOTTY for unimplemented
 functions
Date: Tue, 10 Mar 2009 05:25:04 -0700 (PDT)
Message-ID: <20090310.052504.186614357.davem@davemloft.net>
References: <20090307-patch-01.tilman@imap.cc>
	<20090308-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pebolle@tiscali.nl, hjlipp@web.de
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35879
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752268AbZCJMZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:25:18 -0400
In-Reply-To: <20090308-patch-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun,  8 Mar 2009 16:23:13 +0100 (CET)

> From: Paul Bolle <pebolle@tiscali.nl>
> 
> A number of functions in the usb_gigaset module will return -EINVAL if
> CONFIG_GIGASET_UNDOCREQ is not set. Make these return -ENOTTY as it's
> more specific and it might make it easier to see (from userspace) why
> these functions actually fail.
> 
> Impact: some error return codes changed
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
