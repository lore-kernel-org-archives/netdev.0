From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Wed, 21 Jan 2009 00:37:51 +0100
Message-ID: <200901210037.51622.arnd@arndb.de>
References: <200901202345.47792.arnd@arndb.de> <200901210017.19038.arnd@arndb.de> <20090120.152345.78877396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ceggers@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:65163 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbZATXh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 18:37:56 -0500
In-Reply-To: <20090120.152345.78877396.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 January 2009, David Miller wrote:
> There seems to be a large precendence for this in other USB drivers,
> both for networking and storage. =A0Probably a mutex or other locking
> hierarchy issue.
>=20
> Really, I would just apply this patch as-is. =A0It works, it's pretty
> clean, and every retort has been a misunderstanding or extreme
> nit-picking :-)

Ok, fair enough. Please add my Acked-by then.

On a related topic, can we put something in place that can check for
this error at run-time, like a WARN_ON(is_kernel_stack(addr)) in
dma_map_single?
Since I only copied this code from elsewhere, I would suspect that
there are lots of similar bugs that never get found on common hardware
otherwise.

	Arnd <><
