From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] scm: Don't use struct ucred in NETLINK_CB and
 struct scm_cookie.
Date: Fri, 07 Sep 2012 17:32:03 -0400 (EDT)
Message-ID: <20120907.173203.1282154627743766272.davem@davemloft.net>
References: <1347030446.2484.771.camel@edumazet-glaptop>
	<20120907.144151.1366430170552241987.davem@davemloft.net>
	<87627ple4q.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, serge@hallyn.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757621Ab2IGVcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 17:32:05 -0400
In-Reply-To: <87627ple4q.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 07 Sep 2012 14:25:09 -0700

> Would anyone mind if we changed the name of the field in netlink from
> pid to portid?  It seems to cause a lot of confusion.  We can't change
> the user space fields of course but...

No objections.
