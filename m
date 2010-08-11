From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: add limit for nframes and clean up
 signed/unsigned variables
Date: Wed, 11 Aug 2010 16:12:48 -0700 (PDT)
Message-ID: <20100811.161248.104043270.davem@davemloft.net>
References: <4C627102.1080205@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hawkes@google.com, urs.thuermann@volkswagen.de,
	netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757193Ab0HKXMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 19:12:31 -0400
In-Reply-To: <4C627102.1080205@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 11 Aug 2010 11:44:34 +0200

> This patch adds a limit for nframes as the number of frames in TX_SETUP and
> RX_SETUP are derived from a single byte multiplex value by default.
> Use-cases that would require to send/filter more than 256 CAN frames should
> be implemented in userspace for complexity reasons anyway.
> 
> Additionally the assignments of unsigned values from userspace to signed
> values in kernelspace and vice versa are fixed by using unsigned values in
> kernelspace consistently.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Reported-by: Ben Hawkes <hawkes@google.com>
> Acked-by: Urs Thuermann <urs.thuermann@volkswagen.de>

Applied and I'll queue this up for -stable, thanks.
