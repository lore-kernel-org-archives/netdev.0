From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Mon, 28 Jul 2008 23:57:36 -0400
Message-ID: <1217303856.28682.21.camel@obelisk.thedillows.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:60842 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753171AbYG2D5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 23:57:40 -0400
In-Reply-To: <1217295498.28682.16.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-07-28 at 21:38 -0400, David Dillow wrote:
> Now you keep one copy per NIC, which doubles the memory usage. Just use
> static struct firmware *typhoon_fw;

Just to clarify, loading it per-NIC wastes memory when there is more
than one card in the box. I've got two in one of my test boxes, hence
the count above. I've heard tale of many more of these stuffed into a
single box, though there's better ways to achieve their aims these days.

