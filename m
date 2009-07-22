From: David Miller <davem@davemloft.net>
Subject: Re: b44: device restarts on heavy load
Date: Wed, 22 Jul 2009 08:56:00 -0700 (PDT)
Message-ID: <20090722.085600.04460117.davem@davemloft.net>
References: <4A37B08F.9000809@dupondje.be>
	<4A37B60C.7000303@dupondje.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: info@dupondje.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752946AbZGVPzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 11:55:55 -0400
In-Reply-To: <4A37B60C.7000303@dupondje.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Louis Dupond <info@dupondje.be>
Date: Tue, 16 Jun 2009 17:11:08 +0200

> To be more precise, the error is ISTAT_RFO 0x00004000 /* Receive FIFO
> Overflow */

The problem is that we need to know if a receive FIFO overflow
puts the chip into a state where it must be reset.

And until we know that, we cannot simply exclude that condition
from the reset test.
