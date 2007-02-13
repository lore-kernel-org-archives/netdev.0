From: David Miller <davem@davemloft.net>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 12:19:15 -0800 (PST)
Message-ID: <20070213.121915.18577477.davem@davemloft.net>
References: <1171397612.18944.25.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41993
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750948AbXBMUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:19:17 -0500
In-Reply-To: <1171397612.18944.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Feb 2007 12:13:32 -0800

> [TG3]: Save MSI state before suspend.
> 
> This fixes the following problem:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7969
> 
> The MSI state needs to be saved during suspend.  PCI state saved
> during tg3_init_one() does not contain valid MSI state because
> MSI hasn't been enabled.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
