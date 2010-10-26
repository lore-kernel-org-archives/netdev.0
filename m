From: David Miller <davem@davemloft.net>
Subject: Re: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 13:19:28 -0700 (PDT)
Message-ID: <20101026.131928.193719487.davem@davemloft.net>
References: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wkevils@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758866Ab0JZUTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:19:04 -0400
In-Reply-To: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Wilson <wkevils@gmail.com>
Date: Tue, 26 Oct 2010 22:02:26 +0200

> My question is:
> dev_disable_lro(dev) disable the LRO feature (NETIF_F_LRO) of the
> device. But suppose I have a device where GRO is enabled (and LRO is
> not). And let's say I set forwarding on this device.

GRO is completely different from LRO, and can remain enabled
when forwarding is turned on.
