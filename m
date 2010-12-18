From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 3/3] igb: example of how to update igb to make use
 of in-kernel Toeplitz hashing
Date: Fri, 17 Dec 2010 22:59:03 -0800 (PST)
Message-ID: <20101217.225903.104068606.davem@davemloft.net>
References: <20101218010048.28602.49776.stgit@gitlad.jf.intel.com>
	<20101217.210923.193721885.davem@davemloft.net>
	<AANLkTimuXo+ZJKmz4U38mLd8x-KymJ0BQxTTjDT2bjgy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752787Ab0LRG6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 01:58:35 -0500
In-Reply-To: <AANLkTimuXo+ZJKmz4U38mLd8x-KymJ0BQxTTjDT2bjgy@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 17 Dec 2010 22:53:24 -0800

> Specifically would a 16 bit key/hash work for queue selection or
> would there be cases where we need a 32 bit key/hash result?

Currently for TX 16-bit ought to be enough.
