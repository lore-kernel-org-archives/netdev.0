From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net, compat_ioctl: fix SIOCGMII ioctls
Date: Sun, 08 Nov 2009 20:56:30 -0800 (PST)
Message-ID: <20091108.205630.190896806.davem@davemloft.net>
References: <20091106.204753.223665411.davem@davemloft.net>
	<200911082231.48060.arnd@arndb.de>
	<200911082234.14031.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754173AbZKIE4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 23:56:04 -0500
In-Reply-To: <200911082234.14031.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 8 Nov 2009 22:34:13 +0100

> SIOCGMIIPHY and SIOCGMIIREG return data through ifreq,
> so it needs to be converted on the way out as well.
> 
> SIOCGIFPFLAGS is unused, but has the same problem in theory.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
