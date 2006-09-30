From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/6]: powerpc/cell spidernet low watermark patch.
Date: Sat, 30 Sep 2006 12:30:59 +0200
Message-ID: <200609301230.59776.arnd@arndb.de>
References: <20060929230552.GG6433@austin.ibm.com> <20060929231730.GJ6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, jeff@garzik.org,
	akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:64233 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1750741AbWI3KbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 06:31:21 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060929231730.GJ6433@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Saturday 30 September 2006 01:17 schrieb Linas Vepstas:
> Implement basic low-watermark support for the transmit queue.
> Hardware low-watermarks allow a properly configured kernel
> to continously stream data to a device and not have to handle
> any interrupts at all in doing so. Correct zero-interrupt
> operation can be actually observed for this driver, when the
> socket buffer is made large enough.

Acked-by: Arnd Bergmann <arnd@arndb.de>
