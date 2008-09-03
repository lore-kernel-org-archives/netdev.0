From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Accessing un-mapped page
Date: Wed, 03 Sep 2008 14:38:28 -0700 (PDT)
Message-ID: <20080903.143828.192637455.davem@davemloft.net>
References: <BD3F7F1EFBA6D54DB056C4FFA45140080334A455A8@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756698AbYICVif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 17:38:35 -0400
In-Reply-To: <BD3F7F1EFBA6D54DB056C4FFA45140080334A455A8@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 3 Sep 2008 11:20:34 -0700

> We just root-caused a critical issue that causes fatal error on PPC with 64KB page.
>
> The problem was due to a feature that allows the chip to align the
> Ethernet payload to 64 bytes - those possible extra 64 bytes were
> only added to the SKB allocation and not to the PCI mapping size. In
> this case there is no need to differentiate between the SKB buffer
> size and the PCI mapping size since the chip might actually use the
> extra 64 bytes. The problem becomes fatal if the last 64 bytes of
> the packets are crossing 4KB boundary and in this case the last page
> was not mapped.
>
> Please consider applying - I'm attaching a patch for this issue
> which also includes an update to the version number.

Patch applied, thanks Eilon.
