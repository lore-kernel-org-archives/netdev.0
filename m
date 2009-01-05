From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-next 2/4] firmware: convert acenic driver to
 request_firmware() -- without firmware data
Date: Sun, 04 Jan 2009 16:10:25 -0800 (PST)
Message-ID: <20090104.161025.50402227.davem@davemloft.net>
References: <1230635694.10603.20.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@sgi.com, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
To: jaswinder@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbZAEAKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 19:10:22 -0500
In-Reply-To: <1230635694.10603.20.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Date: Tue, 30 Dec 2008 16:44:54 +0530

> firmware: convert acenic driver to request_firmware()
> 
> We store the firmware in its native big-endian form now, so the loop in
> ace_copy() is modified to use be32_to_cpup() when writing it out.
> 
> We can forget the BSS,SBSS sections of the firmware, since we were
> clearing all the device's RAM anyway. And the text,rodata,data sections
> can all be loaded as a single chunk since they're contiguous (give or
> take a few dozen bytes in between).
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied.
