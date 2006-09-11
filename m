From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Sun, 10 Sep 2006 22:33:45 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FB2C@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <1157952348.31071.411.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Segher Boessenkool" <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:6918 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S964857AbWIKFdy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 01:33:54 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1157952348.31071.411.camel@localhost.localdomain>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:

> I've done:
> 
> #define tw32_rx_mbox(reg, val)	do { wmb();
tp->write32_rx_mbox(tp, reg, val); } while(0)
> #define tw32_tx_mbox(reg, val)	do { wmb();
tp->write32_tx_mbox(tp, reg, val); } while(0)
> 

That should do it.

I think we need those tcpdump after all.  Can you send it to me?

