From: David Miller <davem@davemloft.net>
Subject: Re: AF_PACKET how to get the original netdev from a packet
 received from a bonded master
Date: Wed, 18 Apr 2007 16:25:23 -0700 (PDT)
Message-ID: <20070418.162523.68157230.davem@davemloft.net>
References: <97949e3e0704181605v39e24bh18ac278adc8b823f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992973AbXDRXZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 19:25:20 -0400
In-Reply-To: <97949e3e0704181605v39e24bh18ac278adc8b823f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Laurent Chavey" <chavey@google.com>
Date: Wed, 18 Apr 2007 16:05:27 -0700

> When using PF_PACKET socket with bonded interfaces, there is no
> way to get the slave interface (physical interface) the packet was
> actually received on.

That's right.

There isn't a real good solution to this problem either.
Decapsulation can happen to arbitrary levels, how many
devices should we remember and how to do the reference
counting on that correctly?

As such, I don't think this will ever be provided.
