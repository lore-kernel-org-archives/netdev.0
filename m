From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [DOC]: generic netlink
Date: Tue, 20 Jun 2006 10:02:50 +0200
Message-ID: <20060620080250.GM1376@postel.suug.ch>
References: <1150724482.5815.48.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Lan <jlan@engr.sgi.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:20677 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964995AbWFTICa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 04:02:30 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1150724482.5815.48.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-19 09:41
> // the attributes you want to own
> 
> enum {
>         FOOBAR_ATTR_UNSPEC,
>         FOOBAR_ATTR_TYPE,
>         FOOBAR_ATTR_TYPEID,
>         FOOBAR_ATTR_TYPENAME,
>         FOOBAR_ATTR_OPER,
> 	/* add future attributes here */
>         __FOOBAR_ATTR_MAX,
> };
> 
> #define FOOBAR_ATTR_MAX (__FOOBAR_ATTR_MAX - 1)

One important point about attributes in generic netlink is that
their scope is per command instead of per family as in netlink.
It's not forbidden to use the same set of attribute identifiers
for two separete commands but it should be avoided to have a
single large list of attributes and have every command pick out
the attributes it needs.


> TODO:
> a) Add a more complete compiling kernel module with events.
> Have Thomas put his Mashimaro example and point to it.

I guess we have a legal issue here ;)

> b) Describe some details on how user space -> kernel works
> probably using libnl??

I'll take care of that.
