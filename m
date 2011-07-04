From: David Miller <davem@davemloft.net>
Subject: Re: lost NETIF_F_GRO in cxgb3 during conversion to hw_features?
Date: Mon, 04 Jul 2011 02:27:57 -0700 (PDT)
Message-ID: <20110704.022757.831359414892014493.davem@davemloft.net>
References: <4E11A1D0020000780004BFA7@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: JBeulich@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab1GDJ3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 05:29:04 -0400
In-Reply-To: <4E11A1D0020000780004BFA7@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@novell.com>
Date: Mon, 04 Jul 2011 10:19:44 +0100

> prior to that change of yours, the flag was set unconditionally, while
> now it can be set only through the ioctl. Is that really correct?

Have a look at net/core/dev.c:register_netdevice()

These things get set by default in both ->hw_features and ->features
now.
