From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv8] usbnet: Resubmit interrupt URB if device is open
Date: Thu, 28 Apr 2011 12:56:38 -0700 (PDT)
Message-ID: <20110428.125638.59696446.davem@davemloft.net>
References: <20110427.230011.59678907.davem@davemloft.net>
	<20110428155227.A7B412031F@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	stern@rowland.harvard.edu, bhutchings@solarflare.com,
	linux-usb@vger.kernel.org
To: pstew@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757005Ab1D1T5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 15:57:12 -0400
In-Reply-To: <20110428155227.A7B412031F@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Stewart <pstew@chromium.org>
Date: Thu, 28 Apr 2011 08:43:37 -0700

> Resubmit interrupt URB if device is open.  Use a flag set in
> usbnet_open() to determine this state.  Also kill and free
> interrupt URB in usbnet_disconnect().
> 
> [Rebased off git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git]
> 
> Signed-off-by: Paul Stewart <pstew@chromium.org>

Applied, thank you.
