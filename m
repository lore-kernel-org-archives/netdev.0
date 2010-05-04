From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 03 May 2010 23:05:53 -0700 (PDT)
Message-ID: <20100503.230553.200626786.davem@davemloft.net>
References: <AANLkTikUArEWFhsxpJGCbOPtvQATBKztP0jhZTTsdx7-@mail.gmail.com>
	<4BDF8387.4000303@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: enh@google.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45505
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754213Ab0EDGFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:05:46 -0400
In-Reply-To: <4BDF8387.4000303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 03 May 2010 22:16:39 -0400

> It looks like a bug to me, feel free to send along a patch :)

Is it?  The quoted text is only about setting the value and what
effect setting -1 or whatever has.

For getting the value, the behavior described sounds just fine.

The default for a socket is whatever the kernel-wide default is.
