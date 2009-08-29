From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] tg3: 5717 support part 1
Date: Sat, 29 Aug 2009 15:44:32 -0700 (PDT)
Message-ID: <20090829.154432.90892269.davem@davemloft.net>
References: <1251585276.29660@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752062AbZH2WoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 18:44:19 -0400
In-Reply-To: <1251585276.29660@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 28 Aug 2009 15:27:50 -0700

> This patchset adds two patches for the 5785 and starts support for the
> 5717 ASIC rev.  The 5717 ASIC rev is a new dual-port NetXtreme I server
> controller family that supports MSIX, jumbo frames, TSS and RSS.  The
> devices can operate with copper and / or serdes phys.  This patchset
> gets the ball rolling by taking care of a few housekeeping items and
> then preparing the napi and interrupt routines for multiple interrupt
> vector support.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

The interrupt and NAPI stuff looks much more generic and cleaner now,
nice work!

All applied to net-next-2.6, thanks!
