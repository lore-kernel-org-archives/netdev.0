From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tw32_f() in tg3_write_mem()
Date: Sun, 30 Apr 2006 23:07:19 -0700 (PDT)
Message-ID: <20060430.230719.90327967.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC041BBEE@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14759
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751270AbWEAGHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:07:19 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BBEE@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 30 Apr 2006 22:05:40 -0700

> Reading back the data register is a safe thing to do. This
> guarantees that the data is written before we change the address
> register to the zero value. Without the read, there is a danger of
> the value being written to SRAM address 0 instead of the desired
> address.

Writes can be posted, but they cannot be reordered can they?
