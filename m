From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 9 Jul 2006 01:46:02 +0200
Message-ID: <20060708234602.GH14627@postel.suug.ch>
References: <20060630.133348.68039806.davem@davemloft.net> <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch> <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch> <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch> <1152368076.5272.39.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:31950 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932290AbWGHXpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 19:45:41 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152368076.5272.39.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-08 10:14
> I dont know if i tested for the above specific setup. I have to look at
> my testcases when i get the opportunity.
> The problem is:
> There is no easy way to detect such a deadlock. I think it reduces to
> the same case as eth0->eth0, i.e:

It's very simple. Just use the same method and add a flag if a mirred
is currently in use as Herbert did to qdisc_run().

> I have a dated  patch to mirred (may not apply cleanly) that i believe
> will fix this specific one. Try to see if it also fixes this case you
> have.

This is complete nonsense, fixing a case out of a generic
problem is useless.

> Its the second pathological case tx deadlock essentially and mirred
> could help - it is not the mirred lock really if the attached patch
> fixes it, but i could be wrong.

__LINK_STATE_QDISC_RUNNING will prevent an eventual tx deadlock,
it will not prevent the mirred deadlock.

I think everything has been said about this, since I'm still not
getting the intend of many parts I'm not able to fix these, sorry.
