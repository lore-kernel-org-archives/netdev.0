From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 2 Apr 2008 16:09:43 +0200
Message-ID: <20080402140943.GD20815@postel.suug.ch>
References: <20080331123311.64e4ca37@extreme> <47F13E43.2040404@trash.net> <20080331.130757.199769025.davem@davemloft.net> <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost> <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost> <47F35933.5080305@trash.net> <20080402112103.GB20815@postel.suug.ch> <47F37615.1090502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50240 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487AbYDBOJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 10:09:22 -0400
Content-Disposition: inline
In-Reply-To: <47F37615.1090502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-04-02 14:03
> Yes, I remember some cases but couldn't find them anymore.
> Tt should be fixed IMO since there's not much value in this
> if its used inconsistently.

Absolutely. The most prominent case is link notifications. Although I
think it's only a matter of passing the netlink pid along.
