From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: 07 Dec 2004 08:02:48 -0500
Message-ID: <1102424568.1089.120.camel@jzny.localdomain>
References: <41B0A5B4.6060108@suse.cz> <20041206140214.GA749@postel.suug.ch>
	 <1102386461.1093.26.camel@jzny.localdomain>
	 <20041207124922.GA1371@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michal Ludvig <mludvig@suse.cz>, Andrew Morton <akpm@osdl.org>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041207124922.GA1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-07 at 07:49, Thomas Graf wrote:
> * jamal <1102386461.1093.26.camel@jzny.localdomain> 2004-12-06 21:27
> > On Mon, 2004-12-06 at 09:02, Thomas Graf wrote:
> > 
> > > Your patch would fix this issue but might break various things. The
> > > actual problem is that iproute2 doesn't check the family in its filter.
> > > It blindly assumes that the kernel only returns addresses of the kind it
> > > has requested. I can understand if you think the current behaviour
> > > is wrong but we shouldn't change it in the middle of a stable tree.
> > 
> > Why would it be wrong? The PF_UNSPEC is there for a purpose.
> 
> I don't think it is wrong myself but I understand if someone does.
>  If
> one sends a GETADDR request for PF_INET6 one might expect to either
> receive all ipv6 addresses or none and to only receive all addresess
> of any type if PF_UNSPEC was specified.
> 

Thats debatable.
Its user space that issues the flushing after a response from the
kernel. It happens to be flushing IPV4 addresses.
Thats why your filter in ip is the answer. 

BTW, did the gnet_stats patches to iproute2 ever get merged?
If you have cycles, can you please look at that hang being reported
using older tc with 2.6.10-rc3?

cheers,
jamal
