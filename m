From: =?utf-8?b?0KXQsNC90LrQuNC9INCa0L7QvdGB0YLQsNC90YLQuNC9?=
	<homecreate@list.ru>
Subject: Re: Why linux keeps connected routes when link goes down
Date: Thu, 19 Feb 2009 11:22:12 +0500
Message-ID: <200902191122.13106.homecreate@list.ru>
References: <200902190203.41497.homecreate@list.ru> <20090218.155207.139931991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx30.mail.ru ([94.100.176.44]:18003 "EHLO mx30.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbZBSGWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 01:22:19 -0500
In-Reply-To: <20090218.155207.139931991.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> IP addresses are owned by the "host" rather than specific interfaces
> under Linux.  So just bringing an interface down does not disable
> IP addresses configured to that interface.
Well. Why routes are not in kernel table when interface is DOWN? And why 
routes are still alive if interface is UP, but not RUNNING?
I think it's right when I can't send anything through interface when there is 
no link. But now I have no link and a route to some network with the highest 
metric

--
Konstantin
E-mail homecreate@list.ru
Jabber homecreate@jabber.ru
