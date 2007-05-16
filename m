From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (take 2)] netdev: lockdep classes in register_netdevice
 Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Tue, 15 May 2007 23:17:51 -0700 (PDT)
Message-ID: <20070515.231751.59657428.davem@davemloft.net>
References: <20070516054000.GB967@ff.dom.local>
	<20070515.224725.95062491.davem@davemloft.net>
	<20070516061732.GB1801@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758588AbXEPGRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 02:17:45 -0400
In-Reply-To: <20070516061732.GB1801@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Wed, 16 May 2007 08:17:32 +0200

> BTW - I think some patch on vlan cannot do any harm (at
> least like this previous of mine - with only ppp
> considered), and maybe this all could be forgotten.

Let's wait to see if any new messages show up.

I think how we've seperated PPP from ethernet locking
has annotated things sufficiently for lockdep to see
what's going on even in that VLAN case.
