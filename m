From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Tue, 7 Dec 2004 13:49:22 +0100
Message-ID: <20041207124922.GA1371@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch> <1102386461.1093.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102386461.1093.26.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1102386461.1093.26.camel@jzny.localdomain> 2004-12-06 21:27
> On Mon, 2004-12-06 at 09:02, Thomas Graf wrote:
> 
> > Your patch would fix this issue but might break various things. The
> > actual problem is that iproute2 doesn't check the family in its filter.
> > It blindly assumes that the kernel only returns addresses of the kind it
> > has requested. I can understand if you think the current behaviour
> > is wrong but we shouldn't change it in the middle of a stable tree.
> 
> Why would it be wrong? The PF_UNSPEC is there for a purpose.

I don't think it is wrong myself but I understand if someone does. If
one sends a GETADDR request for PF_INET6 one might expect to either
receive all ipv6 addresses or none and to only receive all addresess
of any type if PF_UNSPEC was specified.

> If user space decides it wants to flush ipv4 addresses blindly that user
> spaces fault. The patch you attached seems legit. did you verify it?

Not yet, it probably has to be applied to iproute.c as well. I'll have
a look at it and do some testing.
