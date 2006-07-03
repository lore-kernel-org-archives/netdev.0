From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon, 3 Jul 2006 13:34:47 +0200
Message-ID: <20060703113447.GU14627@postel.suug.ch>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44A8E211.4090005@trash.net> <44A8E57E.4080805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	greearb@candelatech.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2458 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751032AbWGCLe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 07:34:27 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44A8E57E.4080805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-07-03 11:38
> That wasn't entirely true either, its not inet_check_attr but
> rtnetlink_rcv_message that aborts, and it does this on all
> kernels. Somehow I thought unknown attributes were usually
> ignored ..

This only applies to the first level of rtnetlink attributes,
when using rtattr_parse() unknown attributes are ignored.

Once this ugly rta_buf has disappeared it will become more
consistent.

Patches look good to me except that new iproute binaries
won't work with older kernels anymore?
