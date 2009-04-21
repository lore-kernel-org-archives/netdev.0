From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] tg3: Restore LAA sooner in shutdown sequence
Date: Tue, 21 Apr 2009 01:42:26 -0700 (PDT)
Message-ID: <20090421.014226.231778774.davem@davemloft.net>
References: <1240247960.7027@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54741
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbZDUImf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:42:35 -0400
In-Reply-To: <1240247960.7027@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:58:52 -0700

> After a shutdown reset, the LAA needs to be restored before posting the
> post-reset signature in shared memory.  If the LAA is not restored
> before then, the bootcode will assume the factory default MAC address
> and WOL will not work with the LAA.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
