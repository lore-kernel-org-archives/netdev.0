From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: Tue, 26 Feb 2008 22:51:04 -0800 (PST)
Message-ID: <20080226.225104.175000479.davem@davemloft.net>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753446AbYB0GvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 01:51:05 -0500
In-Reply-To: <ygfprv55egs.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Urs Thuermann <urs@isnogud.escape.de>
Date: 10 Feb 2008 10:48:51 +0100

> * Using strace on tcpdump, it seems that libpcap on Linux uses
>   PF_PACKET/SOCK_DGRAM for PPP interfaces and thus is not affected by
>   my patch.

When given a specific device, libpcap uses SOCK_RAW.

I spent some time seriously considering this change but I
can't because it really can potentially break so much stuff.

Sorry.
