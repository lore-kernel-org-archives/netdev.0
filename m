From: Alexander Aring <aar@pengutronix.de>
Subject: Re: [PATCH] mrf24j40: fix security-enabled processing on inbound
 frames
Date: Tue, 23 Feb 2016 10:29:00 +0100
Message-ID: <56CC265C.2040906@pengutronix.de>
References: <56C60EBA.2070707@zopieux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>,
	zopieux <web@zopieux.com>
To: Alan Ott <alan@signal11.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50424 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750897AbcBWJ3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 04:29:05 -0500
In-Reply-To: <56C60EBA.2070707@zopieux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Alan, do you have some comments about that?

Currently the mrf24j40 goes into a deadlock if a frame with security
enable bit is set. As you see, I helped myself to create this patch and solve
this stupid default behaviour of mrf24j40. :-)

- Alex
