From: jamal <hadi@cyberus.ca>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 06:57:20 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca>
References: <20020718093928.18BC942CD@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>,
   <netfilter-core@lists.netfilter.org>
Return-path: <owner-netdev@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>@shell.cyberus.ca@shell.cyberus.ca
In-Reply-To: <20020718093928.18BC942CD@lists.samba.org>
List-Id: netdev.vger.kernel.org



On Thu, 18 Jul 2002, Rusty Russell wrote:

> Hi all,
>
> 	With four months to go before the feature freeze,

Really? ;->

>
> Connection tracking:

Fix perfomance problems with this thing. You may have seen reports of
performance degradation it introduces. I was hoping to take a look at some
point time hasnt been visiting this side.

>
> iptables:
> 	o Change over to a netlink interface
> 		o Back to add/delete/replace interface + commit.
> 	o Rewrite libiptc to use netlink (to port iptables).

I hope this resolves the current scheme where the whole
add/delete/replace interface + commit happens in user space?
If you use netlink it would make sense to do incremental updates to the
kernel.

cheers,
jamal
