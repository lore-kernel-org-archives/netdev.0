From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net / e100: Fix suspend of devices that cannot be
 power managed
Date: Wed, 17 Jun 2009 19:03:38 -0700 (PDT)
Message-ID: <20090617.190338.69331786.davem@davemloft.net>
References: <200906141606.29754.rjw@sisk.pl>
	<20090614164604.GA19746@rhlx01.hs-esslingen.de>
	<200906142146.47639.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, andi@lisas.de,
	akpm@linux-foundation.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50541
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754562AbZFRCDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:03:34 -0400
In-Reply-To: <200906142146.47639.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sun, 14 Jun 2009 21:46:46 +0200

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> If the adapter is not power-manageable using either ACPI, or the
> native PCI PM interface, __e100_power_off() returns error code, which
> causes every attempt to suspend to fail, although it should return 0
> in such a case.  Fix this problem by ignoring the return value of
> pci_set_power_state() in __e100_power_off().
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Acked-by: Andreas Mohr <andi@lisas.de>

Applied, thanks!
