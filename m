From: Matthew Whitehead <tedheadster@gmail.com>
Subject: Re: [PATCH net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Thu, 7 Nov 2013 16:55:43 -0500
Message-ID: <20131107215543.GA28687@mwhitehe.csb>
References: <1383771418-28616-1-git-send-email-tedheadster@gmail.com>
 <1383781753.7940.38.camel@joe-AO722>
 <20131107214222.GA28471@mwhitehe.csb>
 <1383860994.9263.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:42429 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3KGVzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 16:55:55 -0500
Received: by mail-qc0-f170.google.com with SMTP id n9so1018236qcw.29
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 13:55:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1383860994.9263.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think that's OK if/when there are multiple statements
> in a block after the netif_msg_<type> like:
> 
> 	if (netif_msg_rx_err(ei_local)) {
> 		foo();
> 		bar();
> 	}
> 
> > I did a V2 in this style, but I'll change it to
> > 
> > netif_<level>(struct ei_device *, type, struct net_device *, fmt, ...)
> > 
> > if that is the more preferred style
> 
> Otherwise I think netif_<level> is the "more preferred" style.
> 
> 
Joe,
  I'll do another version using netif_<level> and post it as V2.

- Matthew
