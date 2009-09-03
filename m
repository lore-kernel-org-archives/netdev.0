From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc35815: Disable PM capability
Date: Wed, 02 Sep 2009 23:15:03 -0700 (PDT)
Message-ID: <20090902.231503.196498577.davem@davemloft.net>
References: <1251906680-5828-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754380AbZICGOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:14:48 -0400
In-Reply-To: <1251906680-5828-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu,  3 Sep 2009 00:51:20 +0900

> This chip may report existance of PM registers though they are not
> supported.  Disable PM features by clearing pdev->pm_cap.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Please handle this as a quirk in drivers/pci/quirks.c as that
is the proper place to handle these kinds of exceptions.

The patch should be submitted to the PCI subsystem maintainer.

Thanks!
