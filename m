From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Sun, 11 Jan 2009 13:41:12 -0800 (PST)
Message-ID: <20090111.134112.140046525.davem@davemloft.net>
References: <20090111.040842.86784676.davem@davemloft.net>
	<1231676698.25018.147.camel@macbook.infradead.org>
	<1231678799.25018.195.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38335
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbZAKVlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 16:41:11 -0500
In-Reply-To: <1231678799.25018.195.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 11 Jan 2009 12:59:59 +0000

> So if you build with CONFIG_TIGON3=y, CONFIG_FIRMWARE_IN_KERNEL=n, you
> should see it fail to load the firmware at boot, but then it should load
> it successfully when you bring the device up.

And you won't be able to mount an NFS root filesystem.
