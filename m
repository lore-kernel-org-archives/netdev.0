From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: rx_submit() should return an error code.
Date: Tue, 10 Aug 2010 00:18:55 -0700 (PDT)
Message-ID: <20100810.001855.179947437.davem@davemloft.net>
References: <AANLkTimubaXzLjROeaNB0dV09thKfpLDyaEA-t_yzyV1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, stern@rowland.harvard.edu, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, jglasgow@google.com
To: ellyjones@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753602Ab0HJHSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 03:18:36 -0400
In-Reply-To: <AANLkTimubaXzLjROeaNB0dV09thKfpLDyaEA-t_yzyV1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elly Jones <ellyjones@google.com>
Date: Mon, 9 Aug 2010 18:37:50 -0400

> This patch makes rx_submit() return an error code, and makes some call sites
> that care check the return value. This is important because it lets us properly
> handle cases where the device isn't ready to handle URB submissions (e.g., when
> it is autosuspended under some drivers); previously, we would attempt and fail
> to submit URBs and reschedule ourselves to try and fail again. This patch is
> against Linus's 2.6 repo commit 45d7f32c7a43cbb9592886d38190e379e2eb2226.
> 
> Signed-Off-By: Elizabeth Jones <ellyjones@google.com>

What gets kevent() running again to run the rx_submit() calls when the
device comes back from being suspended?
