From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 15:09:13 +0200
Message-ID: <20060531130913.GE7844@postel.suug.ch>
References: <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei> <20060528153321.GB31822@2ka.mipt.ru> <20060528.233649.22498001.davem@davemloft.net> <1148904686.27078.20.camel@jzny2> <Pine.LNX.4.64.0605301019180.25929@d.namei> <1149076803.5462.36.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, sds@tycho.nsa.gov,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46497 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965003AbWEaNIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 09:08:52 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1149076803.5462.36.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-05-31 08:00
> We could start by just adding a check for NETLINK_GENERIC in your table
> (as is done generally for other netlink families/protocols with SELinux)
> and then do the fine-grained stuff. I think that checking for attributes
> instead of types will need to be generic for all of netlink.

I'm not sure I perfectly understand the check we're heading for, is the
goal to check whether unknown/forbidden attribute types are being
provided by userspace, i.e. compare the provided attribute types against
a list of allowed attribute types maybe in combination with a list of
required permissions for certain attributes?
