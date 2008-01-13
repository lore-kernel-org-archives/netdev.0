From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [XFRM] Remove unused XFRM_STATE_VOID and
 typos (net/xfrm.h)
Date: Sat, 12 Jan 2008 20:12:59 -0800 (PST)
Message-ID: <20080112.201259.209106769.davem@davemloft.net>
References: <eb3ff54b0801120337w2b49ef4bsfb805ac8d28dc712@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753085AbYAMENC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 23:13:02 -0500
In-Reply-To: <eb3ff54b0801120337w2b49ef4bsfb805ac8d28dc712@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Sat, 12 Jan 2008 13:37:34 +0200

> In net/xfrm.h:
> - remove XFRM_STATE_VOID (not in use)
> - correct 3 typos
> 	
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

XFRM_STATE_VOID is there so that a freshly initialized
object does not have a valid state.  So we should not
remove this.
