From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 9 Jul 2006 01:48:19 +0200
Message-ID: <20060708234819.GI14627@postel.suug.ch>
References: <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch> <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37070 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932348AbWGHXr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 19:47:58 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20060708234602.GH14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Graf <tgraf@suug.ch> 2006-07-09 01:46
> __LINK_STATE_QDISC_RUNNING will prevent an eventual tx deadlock,
> it will not prevent the mirred deadlock.

BTW, it will also not protect you from deadlocking on
dev->queue_lock while enqueueing.
