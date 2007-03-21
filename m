From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 13:25:51 +0100
Message-ID: <20070321122551.GU521@postel.suug.ch>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain> <4600B828.1050801@trash.net> <20070321114522.GR521@postel.suug.ch> <46011FBF.90409@trash.net> <46012357.2030701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47304 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752682AbXCUMZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 08:25:30 -0400
Content-Disposition: inline
In-Reply-To: <46012357.2030701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-21 13:21
> Seems like we're lucky, nfnetlink encodes the "subsystem ID"
> in the upper 8 bits of the message type and uses 1 as the
> smallest ID:

Alright, you've been quicker :-)
