From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Tue, 7 Dec 2004 14:17:06 +0100
Message-ID: <20041207131706.GB1371@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch> <1102386461.1093.26.camel@jzny.localdomain> <20041207124922.GA1371@postel.suug.ch> <1102424568.1089.120.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102424568.1089.120.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I don't think it is wrong myself but I understand if someone does. If
> > one sends a GETADDR request for PF_INET6 one might expect to either
> > receive all ipv6 addresses or none and to only receive all addresess
> > of any type if PF_UNSPEC was specified.
> > 
> 
> Thats debatable.
> Its user space that issues the flushing after a response from the
> kernel. It happens to be flushing IPV4 addresses.
> Thats why your filter in ip is the answer. 

Agreed.

> BTW, did the gnet_stats patches to iproute2 ever get merged?

Not sure, I will check that.

> If you have cycles, can you please look at that hang being reported
> using older tc with 2.6.10-rc3?

It's not really related to the gnet_stats code.  stats_lock isn't set
in the action code when using an older iproute2. I haven't tested this
case because it was marked as broken anyway. I compiled an older version
of iproute2 and will look into it today.
