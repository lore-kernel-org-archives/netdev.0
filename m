From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tx transfer padding for full-speed USB
Date: Tue, 24 Apr 2012 04:12:34 -0400 (EDT)
Message-ID: <20120424.041234.2165606076313914657.davem@davemloft.net>
References: <20120424.002808.1711965470884592541.davem@davemloft.net>
	<1335254738-12605-1-git-send-email-inguin@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: inguin@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab2DXIMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:12:53 -0400
In-Reply-To: <1335254738-12605-1-git-send-email-inguin@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo van Lil <inguin@gmx.de>
Date: Tue, 24 Apr 2012 10:05:38 +0200

> The asix.c USB Ethernet driver avoids ending a tx transfer with a zero-
> length packet by appending a four-byte padding to transfers whose length
> is a multiple of maxpacket. However, the hard-coded 512 byte maxpacket
> length is valid for high-speed USB only; full-speed USB uses 64 byte
> packets.
> 
> Signed-off-by: Ingo van Lil <inguin@gmx.de>

Applied.

Please in the future indicate the driver or subsystem you are
modifying in the subject.  In this case prefixing your subject
with "[PATCH] asix: " would have been the appropriate thing
to do.
