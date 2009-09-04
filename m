From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] tc35815: Disable PM capability
Date: Fri, 04 Sep 2009 22:07:35 +0900 (JST)
Message-ID: <20090904.220735.39155328.anemo@mba.ocn.ne.jp>
References: <1251906680-5828-1-git-send-email-anemo@mba.ocn.ne.jp>
	<20090902.231503.196498577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:50731 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755737AbZIDNHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Sep 2009 09:07:39 -0400
In-Reply-To: <20090902.231503.196498577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Sep 2009 23:15:03 -0700 (PDT), David Miller <davem@davemloft.net> wrote:
> > This chip may report existance of PM registers though they are not
> > supported.  Disable PM features by clearing pdev->pm_cap.
> > 
> > Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> 
> Please handle this as a quirk in drivers/pci/quirks.c as that
> is the proper place to handle these kinds of exceptions.
> 
> The patch should be submitted to the PCI subsystem maintainer.

Thanks, I will add quirks to MIPS arch code because this fixup is
required only for internal ether controller in TXx9 SoCs.

---
Atsushi Nemoto
