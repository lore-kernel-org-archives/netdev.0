From: Thomas Voegtle <tv@lio96.de>
Subject: Re: PF_NETLINK, SOCK_DGRAM, 2 => EPROTONOSUPPORT
Date: Tue, 31 Aug 2010 12:15:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1008311213300.3405@er-systems.de>
References: <alpine.LNX.2.00.1008301158360.28658@er-systems.de> <20100830.190619.91328359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from er-systems.de ([85.25.136.202]:54365 "EHLO er-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab0HaKP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 06:15:28 -0400
In-Reply-To: <20100830.190619.91328359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Aug 2010, David Miller wrote:

> From: Thomas Voegtle <tv@lio96.de>
> Date: Mon, 30 Aug 2010 12:02:51 +0200 (CEST)
>
>> Was this intended, that this code snippet doesn't work this way
>> anymore or is this just a bug?
>
> It's an unintended regression.
>
> But nobody noticed it, because almost no-one uses NETLINK_USER.
>
> This might fix it, give it a test:


Yes, that fixes it. Tested with 2.6.35.4 and 2.6.36-rc3.

Thank you,

  Thomas

