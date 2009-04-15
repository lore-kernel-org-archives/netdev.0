From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Wed, 15 Apr 2009 03:14:39 -0700 (PDT)
Message-ID: <20090415.031439.162179625.davem@davemloft.net>
References: <49CB3F6D.2010508@st.com>
	<20090326.020018.26561577.davem@davemloft.net>
	<49CB528E.9060505@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759520AbZDOKOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:14:48 -0400
In-Reply-To: <49CB528E.9060505@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 26 Mar 2009 11:01:50 +0100

> In any case, at first glance, I understand that the urb->transfer_buffer
> directly points to the preallocated skb data.
> These are filled by the HWs. I mean, the buffers are treated by the HW.
> So I guess, the meaning of the rx_fixup functions is just to solve this
> kind of situations.
> In fact, each usb net driver has an own fixup code according to their HW
> specifications.

Now I understand, thanks for the explanation.

Please resubmit your patch for ASIX, and I will apply it.

Thanks!
