From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] scm: Don't use struct ucred in NETLINK_CB and
 struct scm_cookie.
Date: Fri, 07 Sep 2012 14:41:51 -0400 (EDT)
Message-ID: <20120907.144151.1366430170552241987.davem@davemloft.net>
References: <87haralb0u.fsf@xmission.com>
	<1347030446.2484.771.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, serge@hallyn.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab2IGSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:41:54 -0400
In-Reply-To: <1347030446.2484.771.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Sep 2012 17:07:26 +0200

> Seems fine to me, but I am not sure why you kept NETLINK_CREDS()
> defined/used once.

There are two remaining users, kernel/audit.c and scsi netlink.
