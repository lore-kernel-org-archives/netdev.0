From: David Miller <davem@davemloft.net>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 16:30:05 -0700 (PDT)
Message-ID: <20100327.163005.28815553.davem@davemloft.net>
References: <4BAE6C92.2060801@iki.fi>
	<20100327211133.GA3624@electric-eye.fr.zoreil.com>
	<1269732054.8653.155.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, timo.teras@iki.fi, ivecera@redhat.com,
	netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049Ab0C0X3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 19:29:42 -0400
In-Reply-To: <1269732054.8653.155.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 27 Mar 2010 23:20:54 +0000

> I wonder whether there are special rules that need to be followed
> for updating such registers and which the driver is not following,
> or a more general bug in the Realtek chips that should be
> consistently worked-around for all 64-bit registers.

I suspect that MMIO to 64-bit registers in 32-bit chunks is not
reliable with these parts, given all of the information we have so
far.
