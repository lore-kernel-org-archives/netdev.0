From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/5] [NETLINK]: Ignore control messages directly in netlink_run_queue()
Date: Wed, 21 Mar 2007 12:59:56 +0100
Message-ID: <20070321115956.GS521@postel.suug.ch>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.885191779@lsx.localdomain> <4600B828.1050801@trash.net> <20070321114522.GR521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47147 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908AbXCUL7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 07:59:35 -0400
Content-Disposition: inline
In-Reply-To: <20070321114522.GR521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Graf <tgraf@suug.ch> 2007-03-21 12:45
> * Patrick McHardy <kaber@trash.net> 2007-03-21 05:44
> > This looks like it would break nfnetlink, which appears to be
> > using 0 as smallest message type.
> 
> It shouldn't do that, the first 16 message types are reserved
> for control messages.

Alright, even though nfnetlink is wrong and buggy we can't break
it at this point.

Dave, please ignore this last patch for now.
