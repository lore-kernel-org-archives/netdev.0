From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix ACK processing after netlink_dump_start
Date: Tue, 23 Oct 2007 20:29:33 -0700 (PDT)
Message-ID: <20071023.202933.78709167.davem@davemloft.net>
References: <20071023144023.GA15035@iris.sw.ru>
	<20071023163428.GC8125@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, dcbw@redhat.com, jfannin@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752754AbXJXD3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:29:49 -0400
In-Reply-To: <20071023163428.GC8125@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 23 Oct 2007 18:34:28 +0200

> * Denis V. Lunev <den@openvz.org> 2007-10-23 18:40
> > Revert to original netlink behavior. Do not reply with ACK if the
> > netlink dump has bees successfully started.
> > 
> > libnl has been broken by the cd40b7d3983c708aabe3d3008ec64ffce56d33b0
> > The following command reproduce the problem:
> >    /nl-route-get 192.168.1.1
> > 
> > Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> ACK. Thank you for taking care of this.

Applied, thanks everyone!
