From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:21:16 -0800
Message-ID: <20050331142116.50dbc7b3.davem@davemloft.net>
References: <424C6089.1080507@candelatech.com>
	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
	<424C6F82.7030609@candelatech.com>
	<20050331135229.432afff3.davem@davemloft.net>
	<424C73DB.2090501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C73DB.2090501@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 14:04:11 -0800
Ben Greear <greearb@candelatech.com> wrote:

> > You could extend and use ethtool.  That is what it's there for.
> 
> The IOCTLs I need are very specific and will only be used for
> the redirect module.  I don't think it would be worth adding
> a function pointer to the ethtool-ops, but if that is what you
> prefer I can do so.

I'll let Jeff make this call.

> With regard to the compat:  I did a quick search for 'vlan' in that
> file, thinking I'd mimic whatever was done for the .1q module.  There
> is no mention of vlan anywhere in there.

fs/compat_ioctl.c includes some files, perhaps you should check
some of those out.  In particular, what you seek might, just might,
be discoverd in include/linux/compat_ioctl.h

Also see Stephen's commentary wrt. sysfs
