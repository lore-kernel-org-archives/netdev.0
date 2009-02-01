From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 2/2] phylib: Rework suspend/resume code to check
 netdev wakeup capability
Date: Sun, 01 Feb 2009 00:54:32 -0800 (PST)
Message-ID: <20090201.005432.26823195.davem@davemloft.net>
References: <20090128203914.GB14693@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, afleming@freescale.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752103AbZBAIyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 03:54:36 -0500
In-Reply-To: <20090128203914.GB14693@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 28 Jan 2009 23:39:14 +0300

> In most cases (e.g. PCI drivers) MDIO and MAC controllers are
> represented by the same device. But for SOC ethernets we have
> separate devices. So, in SOC case, checking whether MDIO
> controller may wakeup is not only makes little sense, but also
> prevents us from doing per-netdevice wakeup management.
> 
> This patch reworks suspend/resume code so that now it checks
> for net device's wakeup flags, not MDIO controller's ones.
> 
> Each netdevice should manage its wakeup flags, and phylib will
> decide whether suspend an attached PHY or not.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
